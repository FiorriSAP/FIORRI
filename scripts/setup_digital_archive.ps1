<#!
.SYNOPSIS
    Sets up an advanced digital document archive structure on Windows 10 and optionally processes an inbox.

.DESCRIPTION
    Creates folder taxonomy, applies NTFS permissions, sets up metadata CSV, and optionally processes
    an intake folder by validating filenames, applying retention tags, and moving documents.

.PARAMETER RootPath
    Root directory for the archive. Defaults to C:\\DigitalArchive.

.PARAMETER Departments
    Hashtable mapping department codes to names and subfolders.

.PARAMETER InboxPath
    Path to folder watched for new scans/imports. Defaults to RootPath\\00_Admin\\Inbox.

.PARAMETER ProcessInbox
    Switch to enable inbox processing (requires existing files).

.EXAMPLE
    .\\setup_digital_archive.ps1 -RootPath "D:\\Archive" -ProcessInbox

.NOTES
    - Run in PowerShell 5.1+ with administrator rights to assign permissions.
    - Modify the `$DepartmentAcl` section to match your AD groups.
    - OCR is not performed in this script; integrate with ocrmypdf or other tools before calling `Process-InboxItem`.
#>

[CmdletBinding()]
param (
    [string]$RootPath = "C:\\DigitalArchive",
    [hashtable]$Departments = @{
        "00_Admin" = @{ Name = "Administration"; SubFolders = @("Policies", "Templates", "Inbox"); };
        "10_Finance" = @{ Name = "Finance"; SubFolders = @("2024", "2025", "Permanent", "_Archive"); };
        "20_HR" = @{ Name = "HumanResources"; SubFolders = @("Employees", "Policies", "Recruitment", "_Archive"); };
        "30_Operations" = @{ Name = "Operations"; SubFolders = @("Projects", "Vendors", "Logistics", "_Archive"); };
        "40_Sales" = @{ Name = "Sales"; SubFolders = @("Customers", "Opportunities", "Marketing", "_Archive"); };
        "90_Legal" = @{ Name = "Legal"; SubFolders = @("Contracts", "Compliance", "Litigation", "_Archive"); }
    },
    [string]$InboxPath,
    [switch]$ProcessInbox
)

if (-not $InboxPath) {
    $InboxPath = Join-Path $RootPath "00_Admin\\Inbox"
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$timestamp][$Level] $Message"
}

function Initialize-ArchiveStructure {
    Write-Log "Creating root archive at $RootPath"
    if (-not (Test-Path $RootPath)) {
        New-Item -ItemType Directory -Path $RootPath -Force | Out-Null
    }

    foreach ($code in $Departments.Keys | Sort-Object) {
        $dept = $Departments[$code]
        $deptPath = Join-Path $RootPath ("{0}_{1}" -f $code, $dept.Name)
        if (-not (Test-Path $deptPath)) {
            Write-Log "Creating department folder: $deptPath"
            New-Item -ItemType Directory -Path $deptPath -Force | Out-Null
        }

        foreach ($sub in $dept.SubFolders) {
            $subPath = Join-Path $deptPath $sub
            if (-not (Test-Path $subPath)) {
                New-Item -ItemType Directory -Path $subPath -Force | Out-Null
            }
        }
    }

    # Metadata repository
    $metadataPath = Join-Path $RootPath "metadata"
    if (-not (Test-Path $metadataPath)) {
        New-Item -ItemType Directory -Path $metadataPath -Force | Out-Null
    }

    $csvPath = Join-Path $metadataPath "documents.csv"
    if (-not (Test-Path $csvPath)) {
        "FilePath,Department,DocumentType,Counterparty,EffectiveDate,RetentionCode,Confidentiality,Version" | Out-File -FilePath $csvPath -Encoding UTF8
    }

    Write-Log "Archive structure initialized"
}

function Set-DepartmentPermissions {
    Write-Log "Assigning NTFS permissions"
    $DepartmentAcl = @{
        "00_Admin" = @("DOMAIN\\ITAdmins");
        "10_Finance" = @("DOMAIN\\FinanceTeam", "DOMAIN\\ITAdmins");
        "20_HR" = @("DOMAIN\\HRManagers");
        "30_Operations" = @("DOMAIN\\OperationsTeam");
        "40_Sales" = @("DOMAIN\\SalesTeam");
        "90_Legal" = @("DOMAIN\\LegalTeam", "DOMAIN\\GeneralCounsel");
    }

    foreach ($code in $Departments.Keys) {
        $dept = $Departments[$code]
        $deptPath = Join-Path $RootPath ("{0}_{1}" -f $code, $dept.Name)
        if (-not (Test-Path $deptPath)) { continue }

        $acl = Get-Acl $deptPath
        if (-not $DepartmentAcl.ContainsKey($code)) { continue }
        foreach ($group in $DepartmentAcl[$code]) {
            if (-not $group) { continue }
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
            $acl.SetAccessRule($rule)
        }
        Set-Acl -Path $deptPath -AclObject $acl
    }

    Write-Log "Permissions applied. Adjust DOMAIN groups to match your environment." "WARN"
}

function Get-ArchiveDestination {
    param(
        [string]$DepartmentCode,
        [datetime]$EffectiveDate,
        [string]$RetentionCode
    )

    $yearFolder = $EffectiveDate.ToString("yyyy")
    $dept = $Departments[$DepartmentCode]
    if (-not $dept) { return $null }
    $deptPath = Join-Path $RootPath ("{0}_{1}" -f $DepartmentCode, $dept.Name)

    if ($dept.SubFolders -contains $yearFolder) {
        return Join-Path $deptPath $yearFolder
    }
    elseif ($dept.SubFolders -contains "Permanent" -and $RetentionCode -match "PERM") {
        return Join-Path $deptPath "Permanent"
    }
    else {
        return Join-Path $deptPath "_Archive"
    }
}

function Parse-MetadataFromFileName {
    param(
        [string]$FileName
    )
    # Pattern: YYYYMMDD_DEPT_DOCTYPE_SUMMARY_vMajor.Minor.ext
    $pattern = '^(?<date>\d{8})_(?<dept>[A-Z]{2,})_(?<doctype>[A-Z]+)_(?<summary>[^_]+)_v(?<version>\d+\.\d+)'
    $match = [regex]::Match($FileName, $pattern)
    if (-not $match.Success) { return $null }

    $date = [datetime]::ParseExact($match.Groups['date'].Value, 'yyyyMMdd', $null)
    return [pscustomobject]@{
        EffectiveDate = $date
        DepartmentCode = $match.Groups['dept'].Value
        DocumentType = $match.Groups['doctype'].Value
        Summary = $match.Groups['summary'].Value
        Version = $match.Groups['version'].Value
    }
}

function Normalize-DepartmentCode {
    param([string]$RawCode)
    switch ($RawCode.ToUpper()) {
        "ADM" { return "00_Admin" }
        "FIN" { return "10_Finance" }
        "HR" { return "20_HR" }
        "OPS" { return "30_Operations" }
        "SAL" { return "40_Sales" }
        "LEG" { return "90_Legal" }
        default { return $null }
    }
}

function Process-InboxItem {
    param(
        [System.IO.FileInfo]$File
    )

    $meta = Parse-MetadataFromFileName -FileName $File.Name
    if (-not $meta) {
        Write-Log "Skipping file with invalid naming convention: $($File.Name)" "WARN"
        return
    }

    $deptCode = Normalize-DepartmentCode -RawCode $meta.DepartmentCode
    if (-not $deptCode) {
        Write-Log "Department code not recognized for $($File.Name)" "ERROR"
        return
    }

    $retentionCode = Read-Host -Prompt "Enter retention code for $($File.Name)"
    $counterparty = Read-Host -Prompt "Enter counterparty name"
    $confidentiality = Read-Host -Prompt "Enter confidentiality level (Public/Internal/Restricted)"

    $destination = Get-ArchiveDestination -DepartmentCode $deptCode -EffectiveDate $meta.EffectiveDate -RetentionCode $retentionCode
    if (-not $destination) {
        Write-Log "Unable to resolve destination for $($File.Name)" "ERROR"
        return
    }

    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
    }

    $targetPath = Join-Path $destination $File.Name
    Move-Item -Path $File.FullName -Destination $targetPath -Force

    $csvPath = Join-Path $RootPath "metadata\\documents.csv"
    $row = '"{0}","{1}","{2}","{3}","{4:yyyy-MM-dd}","{5}","{6}","{7}"' -f $targetPath, $deptCode, $meta.DocumentType, $counterparty, $meta.EffectiveDate, $retentionCode, $confidentiality, $meta.Version
    Add-Content -Path $csvPath -Value $row

    Write-Log "Archived $($File.Name) to $destination"
}

Initialize-ArchiveStructure
Set-DepartmentPermissions

if ($ProcessInbox) {
    if (-not (Test-Path $InboxPath)) {
        Write-Log "Inbox path $InboxPath does not exist" "ERROR"
        exit 1
    }
    $files = Get-ChildItem -Path $InboxPath -File
    foreach ($file in $files) {
        Process-InboxItem -File $file
    }
}
