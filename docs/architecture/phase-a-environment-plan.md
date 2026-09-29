# Phase A: Environment Preparation Plan

Labels used in this document:
**CONFIRMED** means verified in this environment. **RECOMMENDED** means a design decision. **ASSUMED** means not yet verified. **PROPOSED** means planned and not implemented.

## 1. Resource Inventory and Cost Assessment

> Prices and free allowances change. Check every item marked *verify* against the current Azure pricing pages and your subscription's offer before you deploy it.

| Resource | Exam part | Cost risk | Free/basic approach | Notes |
|---|---|---|---|---|
| Resource Group | All | None | n/a | Name: `MediData-Project-A-<LastName>` |
| Custom RBAC roles + assignments | 1.1 | None | n/a | Needs Owner or User Access Administrator rights. Creating test users needs Entra ID permissions (see Risks) |
| Virtual Network + 3 subnets | 1.2 | None | n/a | VNets are free. Peering and gateways are not, so avoid them |
| 3 Network Security Groups | 1.2 | None | n/a | NSGs are free |
| NSG / VNet flow logs | 2.2 | **Charges** (per GB plus storage) | Use NSG diagnostic logs or activity logs instead, if they meet the requirement | *Verify*: Microsoft is retiring NSG flow logs in favor of VNet flow logs |
| Test VMs (connectivity proof) | 1.2 validation | **Charges** | B1s free hours *if* the offer includes them (*verify*). Otherwise use NSG rule review and documentation-based validation | Decide in Phase C. Never create one without approval |
| Storage Account (Standard, LRS) | 2.1 | Very low (per GB + transactions) | Standard_LRS, tiny synthetic files | No public blob access |
| Key Vault (Standard) | 2.1 | Low (per operation) | Standard tier and software-protected RSA key | The Premium/HSM tier is not needed. CMK requires soft delete + **purge protection**, which means the vault cannot be deleted immediately (see Cleanup) |
| Key auto-rotation (90 days) | 2.1 | Low (*verify* per-rotation charge) | n/a | Exam target is 90 days |
| Log Analytics workspace | 2.2 | Pay per GB ingested | Pay-as-you-go tier, 30-day retention, few sources, daily cap | *Verify* the free ingestion allowance |
| Diagnostic Settings | 2.2 | Cost comes from the data volume | Send only the categories you need | |
| Log search alert rule | 2.2 | **Monthly per-rule charge** (*verify*) | One rule only, and disable it after the demo | |
| Action Group (email) | 2.2 | Free up to a monthly email allowance (*verify*) | Email only, no SMS/voice | |
| Microsoft Defender for Cloud | 2.2 ("Security Center") | Foundational CSPM is free. **Defender plans are paid** | Keep all Defender plans **Off** | "Azure Security Center" is now **Microsoft Defender for Cloud** |
| Azure Policy + compliance | 3.1 | Free for Azure resource policies | Assign the built-in HIPAA HITRUST initiative (*verify* its current name) at RG scope | Microsoft Purview Compliance Manager needs M365 licensing. Check whether your university tenant allows it |

**Services to avoid:** Azure Firewall, Application Gateway/WAF, Bastion, VPN/ExpressRoute gateways, DDoS Protection, Azure SQL (not required; the Data-Subnet stands for the database tier), Sentinel, and Defender paid plans. Each one can cost money quickly.

## 2. IP Addressing Strategy (RECOMMENDED)

| Network | CIDR | Usable* | Purpose |
|---|---|---|---|
| vnet-medidata-a | 10.10.0.0/16 | - | Address space with room to grow |
| Web-Subnet | 10.10.1.0/24 | 251 | Internet-facing tier |
| App-Subnet | 10.10.2.0/24 | 251 | Business logic, port 8080 |
| Data-Subnet | 10.10.3.0/24 | 251 | Database tier, port 1433 |
| (reserved) | 10.10.4.0/22 | - | Future use, for example a Bastion or private endpoints |

\*Azure reserves 5 addresses in every subnet. Private RFC 1918 space that does not overlap common home and university ranges (192.168.x, 10.0.x) avoids conflicts if you add peering or VPN later.

## 3. Naming Conventions (RECOMMENDED)

This pattern follows the Microsoft Cloud Adoption Framework: `<type>-<workload>-<variant>`.

| Resource | Name | Constraint |
|---|---|---|
| Resource Group | `MediData-Project-A-<LastName>` | **Fixed by the exam** |
| VNet | `vnet-medidata-a` | |
| Subnets | `Web-Subnet`, `App-Subnet`, `Data-Subnet` | **Fixed by the exam** |
| NSGs | `nsg-web-subnet`, `nsg-app-subnet`, `nsg-data-subnet` | |
| Storage | `stmedidataa<4-6 random chars>` | 3-24 characters, lowercase letters and numbers only, globally unique |
| Key Vault | `kv-medidata-a-<suffix>` | 3-24 characters, globally unique |
| Key | `cmk-patient-backups` | |
| Log Analytics | `law-medidata-a` | |
| Action Group | `ag-medidata-secops` | Short name of 12 characters or fewer, for example `MediSecOps` |
| Alert rule | `alert-medidata-<scenario>` | |
| RBAC roles | `MediData-SecurityAdmin`, `MediData-DataEngineer`, `MediData-ReadOnlyAuditor` | **Fixed by the exam** |

## 4. Tagging Conventions (RECOMMENDED)

Apply these tags to every resource:

| Tag | Example | Why |
|---|---|---|
| `Project` | `MediData` | Cost grouping |
| `Environment` | `Academic-Lab` | Separates this lab from production |
| `Owner` | `<LastName>` | Accountability. Do not use your email address |
| `DataClassification` | `Synthetic-PHI` | Shows data classification thinking (compliance gap evidence) |
| `ExamPart` | `1.2` | Traceability to the exam |
| `ManagedBy` | `Portal` / `AzureCLI` / `Terraform` | Records how the resource was deployed |
| `DeleteAfter` | `2026-10-31` | Cleanup discipline |

## 5. Deployment Strategy

1. **Portal first** for each exam part, because the exam grades screenshots of the configuration.
2. **Azure CLI script** next, to capture the same configuration so it can be reproduced (portfolio enhancement).
3. **Terraform** is optional, and only after the Portal build is validated. Never keep two deployments of the same resource.
4. Every command runs against an explicitly selected subscription (`az account set`).
5. Deploy one phase at a time, then validate it, capture evidence, and commit.

## 6. Cleanup Strategy

1. Disable the alert rule after the demo, which stops the per-rule charges.
2. Delete the Resource Group: `az group delete --name MediData-Project-A-<LastName>`
3. **Key Vault caveat:** because purge protection is on, the vault stays in a soft-deleted state for the retention period and cannot be purged early. Set the **minimum retention (7 days)** when you create the vault. Soft-deleted vaults are not billed (*verify*), but the vault name stays reserved.
4. Check for leftovers: the `NetworkWatcherRG` resource group, any Defender plans that were enabled, and role definitions. Custom roles live at subscription scope, so delete them with `az role definition delete`.
5. Take a Cost Management screenshot after cleanup as evidence.

## 7. Known Risks for an Academic Subscription (ASSUMED until verified)

| Risk | Impact | Fallback |
|---|---|---|
| You are not Owner/User Access Administrator | You cannot create custom roles | Ask the instructor. Document the limitation |
| University Entra ID blocks creating users or inviting guests | You cannot create test users | Ask the tenant admin for 3 test accounts, or assign the roles to yourself one at a time for testing and document it |
| Region or SKU restrictions (Azure Policy on student offers) | Deployment denied | Use an allowed region. Record the error message as evidence |
| CMK needs a managed identity and the Key Vault Crypto Service Encryption User role | Setup fails without them | Covered in Phase E |
| Defender regulatory standards may need a paid plan | HIPAA view unavailable | Use the Azure Policy compliance dashboard instead |
