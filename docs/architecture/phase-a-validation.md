# Phase A: Environment Validation Results

Labels: **CONFIRMED** means observed in the environment.

| Check | Result | Status | Evidence |
|---|---|---|---|
| Subscription active | `Azure subscription 1`, Enabled | CONFIRMED | `00-environment/subscription-overview-cli.png` |
| Offer type / spending limit | `FreeTrial_2014-09-01`, spending limit **On** | CONFIRMED | `00-environment/subscription-offer-*.jpeg` |
| Operator role | Owner at subscription scope | CONFIRMED | `00-environment/owner-role-cli.jpg` |
| Entra ID role | Global Administrator (can create test users) | CONFIRMED | Noted in text only |
| Azure Policy restrictions | None assigned | CONFIRMED | `az policy assignment list` returned nothing |
| Resource providers (8) | All Registered | CONFIRMED | `00-environment/providers-registered-cli.png` |
| Network quotas | VNets 1000, NSGs 5000 | CONFIRMED | `00-environment/network-quotas-cli.png` |
| Budget alert | Created | CONFIRMED | `00-environment/cost-budget-alert-portal.png` |
| Instructor approval of the subscription | Approved | CONFIRMED | Instructor confirmation |
| Region availability | VNet, NSG, Storage, Key Vault, Log Analytics available in France Central, West Europe, South Africa North, East US | CONFIRMED | `00-environment/region-availability-cli.jpeg` |
| Selected region | `francecentral` | CONFIRMED | |
| Resource Group | `MediData-Project-A-<LastName>` in francecentral, Succeeded, tagged | CONFIRMED | `01-resource-group/rg-overview-*.jpeg` |

## Cost Note

Free Trial with spending limit On: usage beyond the credit disables resources instead of charging a card. The trial has an end date, so grading and the demo must finish before it expires.

## Region Justification

France Central was selected after confirming that every required service is available there. It gives low latency for administration from Cameroon and keeps all MediData resources inside a single geographic and regulatory boundary. Every resource in this project is deployed to that one region.

## Security Note

The operator account is Global Administrator and subscription Owner. Daily administration with these rights would violate least privilege. In Phase B, separate test identities with narrowly scoped custom roles demonstrate the intended access model. MFA should be enforced on the administrator account.

## Troubleshooting Log

**Issue:** `az group show` returned `ResourceGroupNotFound` after the Resource Group appeared to be created in the Portal.

**Diagnosis:** `az group list` showed that no group with the expected name existed. The group had not been submitted, and the intended name also contained the full name instead of the last name only.

**Fix:** The group was created again as `MediData-Project-A-<LastName>`, following the exam rule (last name only), and verified with `az group show` (`Succeeded`).

**Lesson:** Confirm every deployment through a second independent source (CLI or Activity Log) instead of trusting the Portal workflow alone.

**Issue 2:** Screenshot filenames containing `:` could not be committed through github.dev and are invalid on Windows. **Fix:** files renamed locally and re-uploaded. **Lesson:** use lowercase, hyphen-only filenames.
