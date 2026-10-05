# Evidence and Documentation Conventions

## Exam Rules for Screenshots

1. Every screenshot must show the **date and time** from the system clock. Keep the Windows taskbar clock visible. In Cloud Shell, also run `date` before the command.
2. Every screenshot must be clear, legible, and **captioned** in the report. Example: *Figure 3: Resource Group created in France Central with governance tags.*

## Portal + CLI Pairs

Important steps are captured twice:

- **Portal**: shows the configuration as the interface displays it. Include the breadcrumb and the resource name. Zoom the browser to 80-90%.
- **CLI**: shows the same setting as data. Run `clear; date; <command> -o table` so the command and its output are both visible.

Naming: the same base name with `-portal` or `-cli` at the end, for example `rg-overview-portal.png` and `rg-overview-cli.png`.

## Screenshot Layout

```text
docs/screenshots/
├── 00-environment/
├── 01-resource-group/
├── 02-rbac/
├── 03-vnet/
├── 04-nsg/
├── 05-storage/
├── 06-key-vault/
├── 07-monitoring/
├── 08-alerts/
├── 09-compliance/
└── 10-cleanup/
```

Folders are created only when they receive screenshots.

## Redaction Checklist (before committing)

- [ ] No subscription ID, tenant ID, or object IDs
- [ ] No email addresses or student ID
- [ ] No keys, SAS tokens, connection strings, or secrets
- [ ] Unredacted originals stay in `evidence-raw/`, which is git-ignored

## Status Labels

`IMPLEMENTED` · `PROPOSED REMEDIATION` · `CONFIRMED` · `RECOMMENDED` · `ASSUMED` · `PENDING`

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
