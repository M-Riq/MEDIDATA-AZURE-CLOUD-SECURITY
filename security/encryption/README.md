# Data Encryption & Key Management (Exam Part 2.1)

Status: **IMPLEMENTED** and verified by CLI on 2026-10-05/06.

## Resources

| Resource | Name | Key settings |
|---|---|---|
| Storage account | `stmedidatabryan9918` | Standard_LRS, StorageV2, HTTPS only, TLS 1.2, no public blob access, **shared key access disabled**, firewall default **Deny** (bypass AzureServices), system-assigned managed identity |
| Key Vault | `kv-medidata-bryan-22581` | Standard, **RBAC authorization**, soft delete, **purge protection** (permanent), 7-day retention |
| Key | `cmk-medidata-storage` | RSA 3072, operations limited to `wrapKey` / `unwrapKey` |

## Encryption: Before and After (2.1b)

| | Before (D-1) | After (D-3) |
|---|---|---|
| `encryption.keySource` | `Microsoft.Storage` (PMK) | `Microsoft.Keyvault` (**CMK**) |
| Key | Microsoft-managed | `cmk-medidata-storage` in MediData's Key Vault |
| Version in use | n/a | `.../cmk-medidata-storage/f7b90de7...a69d91` |

The storage account references the key **without a version**, so it automatically follows the newest key version after each rotation (picked up within about 24 hours).

Encryption uses **envelope encryption**: data is encrypted with a data encryption key (DEK) managed by Azure Storage; the DEK is wrapped (encrypted) by the CMK. Only the storage account's managed identity can unwrap it.

## Access to the Key (Least Privilege)

| Principal | Role | Scope | Can do |
|---|---|---|---|
| Administrator (user) | Key Vault Crypto Officer | Vault | Create and manage keys and policies |
| Storage account managed identity | Key Vault Crypto Service Encryption User | **Single key only** | Wrap / unwrap only; cannot read, export or delete |

Owner on the subscription does **not** grant key operations: Key Vault separates the management plane (`Actions`) from the data plane (`DataActions`).

## Key Rotation Policy (2.1c)

See `rotation-policy.json`. Verified output:

| Action | Trigger |
|---|---|
| **Rotate** | `timeAfterCreate: P90D` (every 90 days) |
| Notify | `timeBeforeExpiry: P30D` |
| Expiry of each version | `P2Y` |

Cost: about $1 per rotation (Standard tier). The first rotation is due after grading and cleanup.

## Access Tests (Storage, from Phase B)

| # | Test | Identity | Expected | Result |
|---|---|---|---|---|
| T1 | Custom roles have no data-plane permissions | Admin (definition check) | `DataActions` = 0 for all 3 roles | ✅ PASS (0 / 0 / 0) |
| T2 | Retrieve storage access keys | DataEngineer | Keys unusable | ✅ PASS: 2 keys returned, but `allowSharedKeyAccess = false`, so they authenticate nothing |
| T3 | Change storage network settings | DataEngineer | Allowed (known gap) | ⚠️ CONFIRMED GAP: update succeeded (`Deny` → `Deny`, no-op) |
| T4 | Change storage network settings | Auditor | Denied | ✅ PASS: `AuthorizationFailed` |

T1 is configuration-based: a live blob read would be blocked by the storage firewall before RBAC is evaluated, so it would not isolate the role.

T2 shows that the `listKeys` gap documented in `security/rbac/` is **mitigated at the resource level** (shared key access disabled), not by the role.

T3 remediation (PROPOSED, Phase G): Azure Policy to deny storage accounts whose `networkAcls.defaultAction` is not `Deny`.

## Limitations and Proposed Hardening

- Key Vault public network access is enabled (every request still requires Entra ID authentication and RBAC). Firewall or private endpoint: **PROPOSED** (would block Cloud Shell administration).
- Keys are software-protected (Standard tier). HSM-backed keys (Premium / Managed HSM) would add FIPS 140-2 Level 3 protection: **PROPOSED**, not used to avoid cost.
- Purge protection cannot be disabled; after cleanup the vault remains soft-deleted for 7 days (no cost).

Evidence: `docs/screenshots/05-storage/`, `docs/screenshots/06-keyvault/`, `docs/screenshots/07-storage-access-tests/`
