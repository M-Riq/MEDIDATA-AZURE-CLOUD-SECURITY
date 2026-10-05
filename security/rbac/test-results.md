# RBAC Validation Results (Exam Part 1.1)

Date: 2026-10-05 (UTC). Each test was run in a Cloud Shell session signed in as the test user. A pre-check (`echo` of RG, location and RG ID) confirmed the variables and Resource Group visibility before testing.

All results below were **observed**, not assumed.

| ID | User | Action | Expected | Actual | Evidence (error action) |
|---|---|---|---|---|---|
| A1 | medidata-auditor | List resources in RG | ALLOWED | **ALLOWED** (empty list, no error) | `test-auditor-cli` |
| A2 | medidata-auditor | Modify RG tags | DENIED | **DENIED** | `Microsoft.Resources/subscriptions/resourcegroups/write` |
| S1 | medidata-secadmin | Create storage account | DENIED | **DENIED** | `Microsoft.Storage/storageAccounts/write` |
| S2 | medidata-secadmin | Create VNet | DENIED | **DENIED** | `Microsoft.Network/virtualNetworks/write` |
| S3 | medidata-secadmin | Assign audit policy at RG | ALLOWED | **ALLOWED** | Assignment `test-secure-transfer` created at RG scope |
| S4 | medidata-secadmin | Delete that policy assignment | ALLOWED | **ALLOWED** | `S4 deleted OK` |
| D1 | medidata-dataeng | Create storage account (TLS 1.2, no public blob) | ALLOWED | **ALLOWED** | `provisioningState: Succeeded` |
| D2 | medidata-dataeng | Delete storage account | ALLOWED | **ALLOWED** | `D2 deleted OK` |
| D3 | medidata-dataeng | Create VNet | DENIED | **DENIED** | `Microsoft.Network/virtualNetworks/write` |
| D4 | medidata-dataeng | Assign itself Owner (privilege escalation) | DENIED | **DENIED** | `Microsoft.Authorization/roleAssignments/write` |

**Result: 10 of 10 tests matched the expected outcome.**

## Not Yet Tested

- Auditor reading storage data (data plane): no storage account exists yet. Re-test in Phase D.
- DataEngineer changing storage network settings (known limitation): re-test in Phase D.

## Troubleshooting Note

The first test run failed with `argument --resource-group/-g: expected one argument` because shell variables were not set in the test sessions. With an empty scope, the policy command also targeted `/providers/...` instead of the Resource Group, producing a misleading `AuthorizationFailed`. Those results were discarded. Lesson: validate the test environment before trusting a test result.
