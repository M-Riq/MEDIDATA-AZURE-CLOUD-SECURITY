# MediData Solutions: Secure Azure Healthcare Foundation

> **Status:** Phase A (Environment Preparation) is in progress. No Azure resources have been deployed yet.

This project designs, builds, validates, and documents a secure Microsoft Azure foundation for **MediData Solutions**, a fictional mid-sized healthcare company. MediData is moving its patient record management system to Azure.

The project started as the final examination for **ISN 4153: Cloud Computing Security (Setting A, Summer 2026)**. It is also documented as a professional cloud security portfolio project.

---

## Business Problem

Healthcare workloads process sensitive patient information. Moving to the cloud without clear security boundaries can expose MediData to:

- unauthorized access from over-privileged identities
- direct Internet exposure of databases
- attackers moving sideways between tiers after one compromise
- loss of control over the encryption keys that protect backups
- security events that nobody notices because logs are scattered
- regulatory gaps that nobody measures, for example against HIPAA

## Security Objectives

| Objective | Control (planned) | Phase |
|---|---|---|
| Least-privilege identity | 3 custom Azure RBAC roles at Resource Group scope | B |
| Network segmentation / Zero Trust | 1 VNet, 3 subnets, 1 NSG per subnet, default deny | C |
| Encryption at rest | Storage Account encryption | D |
| Customer-controlled keys | Key Vault + Customer-Managed Key, 90-day rotation | E |
| Centralized logging & alerting | Log Analytics, Diagnostic Settings, Alert Rule, Action Group (email) | F |
| Compliance assessment | Azure Policy / compliance dashboard, HIPAA gap analysis | G |

## Target Architecture (planned)

```text
                 Internet
                    |  80/443 only
+-------------------v------------------------------------------+
| Resource Group: MediData-Project-A-<LastName>   (RBAC scope) |
|                                                              |
|  VNet vnet-medidata-a  10.10.0.0/16                          |
|   +-------------------+  8080  +-------------------+  1433   |
|   | Web-Subnet        | -----> | App-Subnet        | ----+   |
|   | 10.10.1.0/24      |        | 10.10.2.0/24      |     |   |
|   | nsg-web-subnet    |        | nsg-app-subnet    |     |   |
|   +-------------------+        +-------------------+     v   |
|                                  +-------------------------+ |
|                                  | Data-Subnet 10.10.3.0/24| |
|                                  | nsg-data-subnet         | |
|                                  +-------------------------+ |
|                                                              |
|  Storage Account (patient backups) <-- CMK -- Key Vault      |
|                                                              |
|  Diagnostic Settings -> Log Analytics -> Alert -> Email      |
|  Azure Policy -> compliance state -> gap analysis            |
+--------------------------------------------------------------+
```

Full design: [`docs/architecture/phase-a-environment-plan.md`](docs/architecture/phase-a-environment-plan.md)

## Exam Requirements vs. Portfolio Enhancements

| Item | Source |
|---|---|
| Resource Group, RBAC roles, VNet/NSGs, Storage, Key Vault/CMK, monitoring/alert, compliance assessment, PDF report, demo | **Required by exam** |
| Threat model, IaC (Azure CLI / Terraform), validation scripts, repository structure, portfolio README | **Portfolio enhancement** |

## Repository Structure

```text
.
├── README.md
├── .gitignore
├── docs/
│   ├── architecture/        # design decisions, IP plan, naming, tagging
│   └── evidence-conventions.md
└── infrastructure/
    └── azure-cli/           # read-only verification and, later, deployment scripts
```

New folders are added only when a phase produces content for them.

## Cost Principles

- Use only free-tier or basic SKUs that the academic subscription allows.
- Before creating any resource that can cost money, document it and ask for explicit approval.
- Delete the whole Resource Group after grading. See the cleanup strategy in the plan.

## Disclaimer

All data is synthetic. This project shows security controls that *support* HIPAA-aligned practice. It does **not** claim that any environment is HIPAA compliant.

## Roadmap

- [ ] A: Preparation
- [ ] B: IAM / RBAC
- [ ] C: Network security
- [ ] D: Storage
- [ ] E: Key Vault + CMK
- [ ] F: Monitoring + logging
- [ ] G: Compliance
- [ ] H: Documentation
- [ ] I: Demo
- [ ] J: Final audit
