# FIORRI Digital Archive Toolkit

This repository contains planning assets and automation scripts for deploying an advanced digital document archive on Windows 10.

## Contents
- `docs/digital_archive_plan.md` – end-to-end implementation roadmap, governance, and operational checklist.
- `docs/retention_policy_template.md` – template for defining retention schedules and approvals.
- `scripts/setup_digital_archive.ps1` – PowerShell script that builds the folder taxonomy, assigns sample permissions, and optionally processes an intake inbox into the archive.

## Quick Start
1. Review and adapt the [implementation plan](docs/digital_archive_plan.md) to match your organization.
2. Update `scripts/setup_digital_archive.ps1` with your Active Directory group names and desired folder structure tweaks.
3. Run the script in an elevated PowerShell session:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\scripts\setup_digital_archive.ps1 -RootPath "C:\\DigitalArchive" -ProcessInbox
   ```
4. Extend the retention template with your regulatory requirements and integrate OCR/metadata capture tools per the plan.

## Next Steps
- Integrate with your chosen Document Management System (DMS).
- Configure scheduled backups and disaster recovery drills.
- Build Power Automate or SAP Business One connectors to push metadata and files directly into the archive.
