# Document Retention Policy Template

Use this template to define retention requirements for each document class stored in the digital archive.

| Retention Code | Department | Document Type | Description | Retention Period | Legal/Regulatory Basis | Responsible Owner | Disposition Method | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FIN-AP-7YR | Finance | Accounts Payable Invoice | Vendor invoices and supporting documents | 7 Years | Local tax law | Finance Controller | Secure shred & delete | Keep digital copy only. |
| FIN-AR-7YR | Finance | Accounts Receivable Invoice | Customer invoices and receipts | 7 Years | Tax/GAAP | Finance Controller | Delete after audit clearance |  |
| HR-EMP-PLUS5 | HR | Employee Personnel File | Contracts, appraisals, disciplinary records | Employment + 5 Years | Labor regulations | HR Director | Secure delete | Move to inactive folder upon termination. |
| LEG-CONTRACT-PERM | Legal | Signed Contracts | Fully executed contracts and amendments | Permanent | Contractual | General Counsel | N/A (permanent) | Review annually for renegotiation. |
| OPS-QA-3YR | Operations | Quality Assurance Reports | Audit trails, QA inspections | 3 Years | ISO 9001 | QA Manager | Secure delete | Export summary to BI tool. |

## How to Use
1. Copy this table into your governance documentation and extend it for all document types.
2. For each new document class:
   - Assign a retention code with department prefix.
   - Specify the regulatory or business driver.
   - Identify the data owner who approves disposal.
3. Update automation scripts to tag files with the retention code (see `setup_digital_archive.ps1`).
4. Schedule review meetings with owners at least annually.

## Approval Log
| Version | Date | Reviewer | Status | Comments |
| --- | --- | --- | --- | --- |
| 1.0 | 2024-04-16 |  | Draft |  |
