# Why Centralized Logging Matters (Exam Part 2.2d)

## Summary

Centralized logging collects logs from every resource into one place (here, the Log Analytics workspace `law-medidata-bryan`). For a healthcare organization, it is the foundation of incident detection, investigation and compliance.

## 1. Incident Detection

- **Correlation across layers:** an attack rarely touches one resource. A single workspace lets one query join NSG events, Key Vault access, storage reads and Activity log changes.
- **Automated alerting:** alert rules run on the central data. Example in this project: more than 5 denied Key Vault requests in 15 minutes fired a Severity 1 alert.
- **No blind spots:** each resource's logs are otherwise kept separately, in different formats and for different durations; analysts would need to check each one manually.

## 2. Incident Investigation (Forensics)

- **Timeline reconstruction:** who did what, from which IP, at what time, across all resources (KQL queries over one dataset).
- **Integrity:** logs leave the resource being attacked. An attacker who compromises a resource cannot easily erase logs stored in a separate workspace with separate permissions.
- **Scope of breach:** storage read logs show which patient files were accessed, which is needed to decide whether breach notification is required.

## 3. Compliance (HIPAA)

| Requirement | How centralized logging supports it |
|---|---|
| Audit controls, 45 CFR 164.312(b) | Records and lets MediData examine activity in systems containing ePHI |
| Information system activity review, 164.308(a)(1)(ii)(D) | Regular review of logs, access reports and incident tracking from one place |
| Security incident procedures, 164.308(a)(6) | Identify, respond to and document incidents |
| Breach Notification Rule, 164.400-414 | Evidence to determine what PHI was affected |
| Documentation retention, 164.316(b)(2) | Policies and records kept 6 years (requires archiving beyond the 30-day lab retention) |

## 4. Operational Benefits

- One access-control point: auditors get read access to logs without access to patient data (least privilege).
- Consistent retention and cost management.
- A base for future SIEM (Microsoft Sentinel) integration.

## Limitations in This Lab

- 30-day retention only (cost); production needs long-term immutable archiving.
- No Sentinel; detection relies on individual alert rules.
- The alert email was not received (mail filter); production should use multiple notification channels.

## References

- Microsoft Learn: Diagnostic settings in Azure Monitor
- Microsoft Learn: Log Analytics workspace overview
- Microsoft Learn: Azure Key Vault logging
- U.S. HHS: HIPAA Security Rule, 45 CFR Part 164 Subpart C
- NIST SP 800-92: Guide to Computer Security Log Management
