# Compliance Assessment, Gap Analysis and Remediation (Exam Part 3.1)

Status: assessment **IMPLEMENTED**; gaps 1 and 2 **REMEDIATED** on 2026-10-07; final rescan started 06:55 UTC.

## 3.1(a) Assessment Tool

| Item | Value |
|---|---|
| Tool | Azure Policy compliance dashboard |
| Initiative | Built-in **HITRUST/HIPAA** (`a169a624-5599-4385-a696-c8d643089fab`) |
| Assignment | `medidata-hipaa-hitrust` (display: `MediData - HITRUST/HIPAA (audit)`) |
| Scope | Resource Group `MediData-Project-A-Bryan` |
| Enforcement | `DoNotEnforce` (audit only: reports, blocks nothing, deploys nothing) |
| Managed identity | System-assigned, **no roles granted** |

### Why this tool

| Option | Used | Reason |
|---|---|---|
| Azure Policy + HITRUST/HIPAA initiative | Yes | Free, scoped to the RG, explicitly allowed by the brief |
| Microsoft Purview Compliance Manager | No | Focused on Microsoft 365; HIPAA template needs premium licensing |
| Defender for Cloud regulatory standards | No | Adding HIPAA requires the paid Defender CSPM plan |

### Initial results (2026-10-07)

Combined view (HIPAA + Microsoft cloud security benchmark assigned automatically by Defender for Cloud): **6 non-compliant resources, 2 non-compliant policy assignments**.

HIPAA assignment findings:

| Policy | Resource | HITRUST control groups |
|---|---|---|
| `keyvaultshoulduseavirtualnetworkserviceendpoint` | kv-medidata-bryan-22581 | 01.m, 09.m |
| `storageaccountsshoulduseavirtualnetworkserviceendpoint` | stmedidatabryan9918 | 01.m, 09.m |
| `auditdiagnosticsetting` | kv-medidata-bryan-22581 | 09.aa |
| `networksecuritygroupsonsubnetsmonitoring` | web-, app-, data-subnet | 01.m, 01.n |

### Validation of findings

- **NSG on subnets: false positive.** `az network vnet subnet list` shows Web-, App- and Data-Subnet each associated with its NSG. The policy relies on a Defender for Cloud assessment that can lag behind configuration. Lesson: verify every finding against the real configuration.
- **DDoS protection** (benchmark only): valid, but Azure DDoS Network Protection costs about USD 2,900/month; proposed only.

## 3.1(b) Gap Analysis: Two Key Gaps

### Gap 1: PHI stores reachable from public networks

- **Finding:** The Key Vault (holding the CMK) and the storage account (holding patient data) had no VNet service endpoint or private endpoint, and the Key Vault firewall allowed all networks.
- **Evidence:** `keyvaultshoulduseavirtualnetworkserviceendpoint`, `storageaccountsshoulduseavirtualnetworkserviceendpoint`; benchmark findings for Key Vault firewall, Key Vault private endpoint and storage private link.
- **Requirements:** HIPAA 45 CFR 164.312(a)(1) access control, 164.312(e)(1) transmission security; HITRUST 01.m segregation in networks, 09.m network controls.
- **Risk:** Anyone holding stolen credentials could reach the encryption key and patient data from any internet address.

### Gap 2: Key Vault audit logging not configured as required

- **Finding:** The Key Vault diagnostic setting used the `allLogs` category group (with `audit` disabled) instead of the named `AuditEvent` category the policy checks for.
- **Evidence:** `auditdiagnosticsetting`. Recorded before-state (2026-10-07 00:56 UTC): `allLogs: true`, `audit: false`.
- **Requirements:** HIPAA 164.312(b) audit controls; HITRUST 09.aa audit logging.
- **Risk:** Auditors cannot demonstrate that every access to the key protecting PHI is recorded in a way that matches the control.

## 3.1(c) Remediation Plan

| # | Action (Azure) | Gap | Status |
|---|---|---|---|
| 1 | Set Key Vault diagnostic setting to named categories `AuditEvent` + `AzurePolicyEvaluationDetails`, AllMetrics, to `law-medidata-bryan` | 2 | **IMPLEMENTED** |
| 2 | Add `Microsoft.KeyVault` and `Microsoft.Storage` service endpoints to Data-Subnet | 1 | **IMPLEMENTED** |
| 3 | Storage firewall: default Deny, bypass AzureServices, VNet rule for Data-Subnet | 1 | **IMPLEMENTED** |
| 4 | Key Vault firewall: default Deny, bypass AzureServices (keeps CMK working), VNet rule for Data-Subnet | 1 | **IMPLEMENTED** |
| 5 | Private endpoints for Key Vault and storage, with Private DNS zones; disable public network access | 1 | PROPOSED (about USD 7-8/month each) |
| 6 | Assign Azure Policy with **Deny** effect: storage accounts and key vaults must restrict network access; resources must have diagnostic settings (DeployIfNotExists) | 1, 2 | PROPOSED; also stops DataEngineer from reopening storage networking (finding from D-5 tests) |
| 7 | Log retention: archive to immutable storage for 6 years (HIPAA documentation retention 164.316(b)(2)) | 2 | PROPOSED |
| 8 | Microsoft Purview / Azure Information Protection for data classification of PHI | Additional | PROPOSED |
| 9 | Azure DDoS Network Protection on `vnet-medidata-a` | Additional | PROPOSED (cost) |

### Verification after remediation (2026-10-07 06:53 UTC)

| Resource | defaultAction | bypass | VNet rules |
|---|---|---|---|
| Key Vault | Deny | AzureServices | 1 |
| Storage | Deny | AzureServices | 1 |

- Data-Subnet service endpoints: `Microsoft.KeyVault`, `Microsoft.Storage`.
- `az keyvault key list` from Cloud Shell: **ForbiddenByFirewall** (outside access blocked).
- Storage encryption: `Microsoft.Keyvault`, key `cmk-medidata-storage`, status `available` (CMK still works via trusted services).
- Rescan started 06:55 UTC; expected remaining finding: only the NSG false positive.

### Operational impact

Cloud Shell is outside the VNet, so Key Vault data-plane commands are denied. For administration or demo, add a temporary `/32` IP rule and remove it afterwards (see `deploy-compliance.sh`).

Evidence: `docs/screenshots/09-compliance/`

## References

- Microsoft Learn: Azure Policy regulatory compliance, HITRUST/HIPAA built-in initiative
- Microsoft Learn: Configure Azure Key Vault networking settings
- Microsoft Learn: Configure Azure Storage firewalls and virtual networks
- Microsoft Learn: Virtual network service endpoints
- U.S. HHS: HIPAA Security Rule, 45 CFR Part 164 Subpart C
