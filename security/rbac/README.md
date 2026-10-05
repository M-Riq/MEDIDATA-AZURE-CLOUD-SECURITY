# Custom RBAC Roles (Exam Part 1.1)

Status: **IMPLEMENTED** (roles created and assigned at Resource Group scope). Validation tests: **PENDING** (step B-6).

## Roles

| Role | Allowed | Blocked | Assigned to |
|---|---|---|---|
| MediData-ReadOnlyAuditor | `*/read` (management plane only) | Any write/delete; no data-plane access | medidata-auditor |
| MediData-SecurityAdmin | Read all, Defender for Cloud (`Microsoft.Security/*`), policy assignments/exemptions, policy insights, log search | Creating/deleting workload resources; enabling paid Defender plans (`pricings/write`) | medidata-secadmin |
| MediData-DataEngineer | Read all, `Microsoft.Storage/*`, `Microsoft.Sql/*`, deployments | Networking (no `Microsoft.Network` writes, SQL firewall/VNet rules), security policies, SQL auditing/threat detection, role assignments | medidata-dataeng |

Scope for every role and assignment: `/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/MediData-Project-A-<LastName>`.

## Design Decisions

- **Management vs. data plane:** `DataActions` is empty in all roles. Configuration access does not grant access to patient data.
- **Separation of duties:** the security role cannot build or delete systems; the data role cannot change network or security controls.
- **Cost guardrail:** SecurityAdmin cannot enable paid Defender plans.

## Known Limitations

1. `NotActions` is not a deny. It only subtracts from the same role. A second role could grant the action back.
2. Storage firewall settings are part of `storageAccounts/write`, so DataEngineer can change them. Mitigation (PROPOSED): Azure Policy denying public network access on storage (Phase G).
3. `Microsoft.Storage/*` includes `listKeys`, which bypasses the empty `DataActions`. Mitigation (PROPOSED): disable shared-key access on the storage account (Phase D).
4. Most Defender for Cloud settings are subscription-scoped, so SecurityAdmin cannot change them from a Resource Group role. This is intentional; actual behavior is verified in B-6.

## Deploy

```bash
SUBID=$(az account show --query id -o tsv)
RG="MediData-Project-A-<LastName>"
for f in auditor-role.json securityadmin-role.json dataengineer-role.json; do
  sed -e "s|<SUBSCRIPTION_ID>|$SUBID|" -e "s|MediData-Project-A-<LastName>|$RG|" "$f" > "/tmp/$f"
  az role definition create --role-definition @"/tmp/$f"
done
```

Evidence: `docs/screenshots/02-rbac/`
