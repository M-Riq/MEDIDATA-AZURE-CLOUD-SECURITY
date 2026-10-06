# Security Monitoring (Exam Part 2.2)

Status: **IMPLEMENTED** and verified on 2026-10-06.

## 2.2(a) Defender for Cloud and Azure Monitor

| Component | Setting |
|---|---|
| Resource providers | `Microsoft.Security`, `Microsoft.Insights`, `Microsoft.OperationalInsights`: Registered |
| Defender for Cloud | **Foundational CSPM (free)**: Secure Score, recommendations, regulatory dashboard |
| Paid Defender plans | All **Free / off** (VirtualMachines, StorageAccounts, KeyVaults, CloudPosture (Defender CSPM), etc.) |
| Azure Monitor | Built-in; connected to Log Analytics and alerting below |

Defender for Cloud is enabled per **subscription**; the setting covers every resource in `MediData-Project-A-Bryan`.

Verified plan table (`az security pricing list`): only `Discovery` and `FoundationalCspm` show `Standard`, and both are free.

## 2.2(b) Log Analytics Workspace and Diagnostic Settings

Workspace: `law-medidata-bryan` (francecentral, PerGB2018, 30-day retention).

"All platform logs and metrics" = every category each resource exposes (checked with `az monitor diagnostic-settings categories list`):

| Resource | Logs sent | Metrics sent |
|---|---|---|
| VNet `vnet-medidata-a` | VMProtectionAlerts | AllMetrics |
| NSGs `nsg-web-subnet`, `nsg-app-subnet`, `nsg-data-subnet` | NetworkSecurityGroupEvent, NetworkSecurityGroupRuleCounter | none offered |
| Storage account | none at account level | Transaction |
| Storage blob service | StorageRead, StorageWrite, StorageDelete | Transaction |
| Key Vault (extra) | AuditEvent, AzurePolicyEvaluationDetails | AllMetrics |
| Subscription Activity log | Administrative, Security, Policy, Alert | n/a |

All diagnostic settings are named `diag-to-law` (subscription: `diag-activity-to-law`) and were verified to target `law-medidata-bryan`.

Capacity metrics are viewable in Azure Monitor Metrics but were not exported through diagnostic settings.

## 2.2(c) Alert Rule and Email Notification

| Item | Value |
|---|---|
| Action group | `ag-medidata-security` (short name `MediSecOps`), email receiver `secops-email` |
| Alert rule | `alert-kv-excessive-auth-failures` |
| Security event | Excessive authorization failures against the Key Vault holding the patient-data CMK |
| Query | See `alert-query.kql` |
| Threshold | count > 5 in a 15-minute window, evaluated every 15 minutes |
| Severity | 1 (Error) |

### Why this event
The environment has no VMs or databases, so SQL injection or VM sign-in alerts would never fire. Repeated 401/403 responses from the Key Vault indicate someone trying to use the encryption key without permission, which is a direct threat to PHI confidentiality.

### Test

| Step | Result |
|---|---|
| Trigger | 8 `az keyvault key list` calls as the Auditor test user (no Key Vault data role) |
| Alert | **Fired** 2026-10-06 07:26 UTC; an earlier firing **Resolved** at 05:46 UTC |
| Email | Not received: likely blocked by the recipient's mail filter. The fired alert in Azure Monitor is the evidence of detection |

## Limitations and Proposed Improvements

- No Microsoft Sentinel (SIEM/SOAR): **PROPOSED** for correlation and automated response.
- 30-day retention: HIPAA documentation retention is 6 years; production would archive logs to immutable storage. **PROPOSED**.
- No VM or application logs (no compute deployed).
- Paid Defender plans (for example Defender for Storage malware scanning) not enabled because of cost: **PROPOSED**.
- Email delivery not confirmed; production would add a second channel (SMS, Teams or ITSM webhook).

Evidence: `docs/screenshots/08-monitoring/`
