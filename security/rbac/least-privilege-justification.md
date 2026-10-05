# Least Privilege Justification (Exam Part 1.1c)

## Why Least Privilege Is Critical for MediData

MediData stores protected health information (PHI). Every permission granted is a permission an attacker inherits if that account is phished, its password reused, or its session token stolen. Least privilege limits the **blast radius** of a compromised identity: the attacker can only do what that one role allows, only inside one Resource Group.

It also supports healthcare regulation. The HIPAA Security Rule requires access controls and the "minimum necessary" use of PHI. Least privilege is one technical control that supports these requirements; it does not by itself make an organization compliant.

It enforces **separation of duties**: no single role can both change security controls and build or delete the systems those controls protect.

## Example 1: Data Engineer Cannot Open the Network

| | |
|---|---|
| Problem | Engineers need full control of storage, but a storage administrator who can also change networking could expose patient backups to the Internet. |
| Control | `MediData-DataEngineer` has `Microsoft.Storage/*` but no `Microsoft.Network` writes, no SQL firewall/VNet rule writes, and no `Microsoft.Authorization` actions. |
| Validation | D1/D2 ALLOWED (storage create/delete). D3 DENIED (`virtualNetworks/write`). D4 DENIED (`roleAssignments/write`, self-assign Owner). |
| Result | A compromised engineer account can manage storage but cannot open network paths or grant itself more power (privilege escalation blocked). |

## Example 2: Security Admin Cannot Build or Destroy Systems

| | |
|---|---|
| Problem | The security team must manage policies, but a stolen security account should not be able to delete patient-data storage or create attacker-controlled infrastructure. |
| Control | `MediData-SecurityAdmin` has policy and Defender permissions plus read, with no workload write/delete and no ability to enable paid Defender plans. |
| Validation | S3/S4 ALLOWED (policy assign/delete). S1 DENIED (`storageAccounts/write`). S2 DENIED (`virtualNetworks/write`). |
| Result | Security configuration is separated from resource lifecycle. |

## Additional Applications

- **Scope:** every role is assignable and assigned only at `MediData-Project-A-<LastName>`, never the subscription.
- **Management vs. data plane:** no role has `DataActions`. Seeing a storage account's configuration does not grant reading patient files.
- **Auditor:** `*/read` only. A2 DENIED (`resourcegroups/write`) proves an auditor cannot alter the evidence they review.

## Residual Risks

See `README.md` > Known Limitations (NotActions is not a deny, storage network settings, listKeys, subscription-scoped Defender settings). Mitigations are PROPOSED for Phases D and G.
