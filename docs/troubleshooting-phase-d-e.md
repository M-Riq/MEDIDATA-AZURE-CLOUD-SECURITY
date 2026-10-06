# Troubleshooting Log: Phases D and E

| # | Symptom | Cause | Fix / Lesson |
|---|---|---|---|
| 1 | `bash: kv-medidata-bryan-22581: command not found` when sourcing `env.sh` | Line missing `KV=`; bash ran the value as a command | Every line must be `NAME="value"` |
| 2 | Role list showed only Crypto Officer | `date` was pasted onto the `KEYSCOPE=` line, so the scope pointed at a non-existent key | Put each command on its own line; echo variables before using them |
| 3 | `principalType` column empty in `az role assignment list` | Field not populated by this CLI version | Role names are sufficient evidence; Portal IAM view shows principal names |
| 4 | Rotation policy `show` returned `null` fields | Query used the upload JSON schema; the CLI returns a flattened schema | Inspect raw `-o json` before writing JMESPath queries |
| 5 | DataEngineer tests failed with `AuthorizationFailed` on scope `resourceGroups/providers/...` | Each Entra ID user has an isolated Cloud Shell; `env.sh` existed only in the admin session | Recreate variables per user; confirm a test reached the intended resource before treating a denial as evidence. Screenshot of that run discarded (exposed IDs) |
| 6 | `Signed: command not found` in the Auditor shell | Extra output text pasted into `env.sh` | Rewrote the file with only the needed variables |
| 7 | `az security pricing list` filter returned `Discovery`, `FoundationalCspm` | Free entries report tier `Standard` | Listed all plans with tiers; all paid plans confirmed `Free` |
| 8 | `az monitor log-analytics query`: *Timeout waiting for token from portal (audience api.loganalytics.io)* | Cloud Shell could not obtain a Log Analytics data-plane token | Ran the same KQL in the Portal Logs blade |
| 9 | Alert fired but no email received | Probably a recipient mail filter | Fired alert in Azure Monitor used as evidence; production should add a second notification channel |
