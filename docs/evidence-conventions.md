# Evidence and Documentation Conventions

## Screenshot Layout (created as each phase produces evidence)

```text
docs/screenshots/
├── 01-resource-group/
├── 02-rbac/
├── 03-vnet/
├── 04-nsg/
├── 05-storage/
├── 06-key-vault/
├── 07-monitoring/
├── 08-alerts/
└── 09-compliance/
```

## Filenames

Use the pattern `<area>-<resource>-<what-it-shows>.png`, in lowercase with hyphens.
Examples: `rbac-securityadmin-role-definition.png`, `web-subnet-nsg-inbound-rules.png`, `storage-cmk-configuration.png`.

## Redaction Checklist (before committing)

- [ ] No subscription ID or tenant ID. Blur them, or show only the last 4 characters
- [ ] No email addresses, student ID, or real names beyond your last name
- [ ] No keys, SAS tokens, connection strings, or secrets
- [ ] No object IDs that aren't needed
- [ ] Keep unredacted originals in `evidence-raw/`, which is git-ignored

## Status Labels (required in every document)

`IMPLEMENTED` · `PROPOSED REMEDIATION` · `CONFIRMED` · `RECOMMENDED` · `ASSUMED`

## Control Documentation Template

```text
Security problem:
Threat:
Control:
Configuration:
Validation (test + expected + ACTUAL result):
Result / residual risk:
Evidence: <screenshot paths>
```

Never record a test result that was not actually observed.
