# Troubleshooting Log: Phase G (Compliance)

| # | Symptom | Cause | Fix / Lesson |
|---|---|---|---|
| 1 | `az policy assignment create` with full initiative ID: `PolicySetDefinitionNotFound`, then CLI crash `'NoneType' object has no attribute 'get'` | CLI bug resolving built-in initiatives by full ID | Passed the initiative name (GUID) only |
| 2 | Results mixed two assignments (names ending in `monitoringeffect`) | Defender for Cloud assigns the Microsoft cloud security benchmark at subscription level | Filtered on `policyAssignmentName eq 'medidata-hipaa-hitrust'` |
| 3 | NSG-on-subnet finding for all 3 subnets | Policy depends on a lagging Defender assessment | CLI showed all NSGs associated: treated as false positive. Verify findings against real config |
| 4 | Key Vault lookups failed: vault `kv-medidata-bryan-22581 LAW=law-medidata-bryan` not found | `KV` and `LAW` on one line in `env.sh` | Deleted the line, wrote each variable on its own line, reloaded |
| 5 | `KVID=$(...) date` left `KVID` empty | A variable assignment before a command applies only to that command | One command per line |
| 6 | Command waiting at `>` prompt | Multi-line command pasted incompletely | Ctrl+C; use single-line commands |
| 7 | Key Vault diag "before" screenshot not captured | Fix applied before the screenshot | Before-state recorded in text; dashboard finding used as evidence. Capture before-state first |
| 8 | Storage commands succeeded, Key Vault commands failed in the same block | Broken `KV` reloaded in a new Cloud Shell session | Echo variables at the start of every session |
| 9 | `No subnet or ip address supplied` yet success message printed | `$SUBID` empty after Cloud Shell reset; CLI did not return failure | Verify the result (`vnetRules: 1`), not the echo message |
| 10 | `az keyvault key list` returns ForbiddenByFirewall | Expected: Cloud Shell is outside Data-Subnet | Used as evidence; temporary /32 IP rule for admin or demo |
