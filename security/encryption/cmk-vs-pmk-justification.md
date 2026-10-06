# CMK vs PMK Justification (Exam Part 2.1d)

## Definitions

| | Platform-Managed Key (PMK) | Customer-Managed Key (CMK) |
|---|---|---|
| Who creates and holds the key | Microsoft | MediData, in its own Key Vault |
| Who controls rotation | Microsoft | MediData (policy: every 90 days) |
| Who can revoke access | Nobody but Microsoft | MediData, instantly (disable key or remove role) |
| Key usage audit | Not visible to the customer | Every wrap/unwrap is logged in Key Vault |
| Encryption strength | AES-256 | AES-256 (same) |

Both encrypt the data equally well. The difference is **control and accountability**, not the algorithm.

## Why CMK Is Critical for MediData

1. **Control and revocation (crypto-shredding).** If the environment is compromised or a contract ends, MediData can disable the key. The storage account then can no longer unwrap its data keys and patient data becomes unreadable, even to the cloud provider's own platform.
2. **Separation of duties.** The storage administrator (DataEngineer role) cannot touch the key; the key administrator does not manage storage. Compromising one role is not enough to both access and decrypt data.
3. **Auditability.** Key Vault records each use of the key. With diagnostic settings (Part 2.2), these events go to Log Analytics, supporting the HIPAA requirement for audit controls (45 CFR 164.312(b)).
4. **Rotation under MediData's policy.** The organization sets and can prove its own rotation period (90 days), which supports its documented key management procedures.
5. **Regulatory alignment.** HIPAA treats encryption as an addressable safeguard (45 CFR 164.312(a)(2)(iv)) and guidance stresses that keys must be protected and managed by the covered entity. Encrypted PHI with keys under the entity's control strengthens the safe-harbor position in breach notification (HHS guidance on unsecured PHI).
6. **Protection against key destruction.** Soft delete and purge protection prevent an attacker or insider from permanently deleting the key to hold data hostage.

## Trade-offs (Honest Assessment)

- **Operational risk:** if MediData loses or disables the key by mistake, the data is unavailable. Mitigated by soft delete, purge protection and restricted roles.
- **Cost and complexity:** Key Vault operations and rotations cost a small amount and require role management.
- CMK does **not** protect against a user who is authorized to read the data; RBAC and network controls are still required.

## Conclusion

For a healthcare organization storing PHI, CMK is justified because it gives MediData provable, independent control over who can decrypt patient data, when keys change, and how to revoke access, which PMK cannot provide.

## References

- Microsoft Learn: Customer-managed keys for Azure Storage encryption
- Microsoft Learn: Configure cryptographic key auto-rotation in Azure Key Vault
- Microsoft Learn: Azure Key Vault soft-delete and purge protection
- U.S. HHS: HIPAA Security Rule, 45 CFR Part 164 Subpart C
- U.S. HHS: Guidance to Render Unsecured PHI Unusable, Unreadable, or Indecipherable
