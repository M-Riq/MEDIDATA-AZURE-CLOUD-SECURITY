# Zero Trust and Lateral Movement (Exam Part 1.2c)

## Principle

Zero Trust means **never trust based on network location; verify every flow**. Being inside the MediData VNet grants nothing by itself. Each tier accepts only the one port it needs, from the one tier that needs it.

## How the Design Applies It

1. **Explicit allow, everything else denied.** Each NSG has one allow rule (priority 100) and an explicit `Deny-All-Inbound` (priority 4096).
2. **Overriding implicit trust.** Azure's default rule `AllowVnetInBound` (65000) allows any VNet host to reach any other on any port. Because 4096 is evaluated before 65000, that implicit internal trust is removed.
3. **Source-restricted rules.** Data accepts 1433 only from `10.10.2.0/24`, not from the whole VNet.
4. **Least privilege on ports and protocol.** TCP only, single destination ports, destination limited to the tier's own subnet.

## Preventing Lateral Movement

Lateral movement is an attacker moving from a first compromised system toward valuable data.

| Attack step | Without our design | With our design |
|---|---|---|
| Web server compromised via a web vulnerability | Attacker has a foothold | Same: Web must be public |
| Attacker connects Web -> Data on 1433 | ALLOWED by 65000 | **DENIED** by data 4096 (only App may connect) |
| Attacker scans App for SSH/RDP (22/3389) | ALLOWED by 65000 | **DENIED** by app 4096 (only 8080) |
| Attacker reaches the database | Direct path exists | Must also compromise the App tier through port 8080 |

The attacker must break **two** separate tiers to reach PHI, and each attempt to use a blocked port is denied (and can be logged with NSG flow logs in Phase F). This shrinks the blast radius of a single compromise.

## Limits (Honest Assessment)

- NSGs filter by IP and port, not identity. A compromised App server can still legitimately use 1433. Database authentication and encryption (Phase D) are still required.
- Outbound traffic is not yet restricted, so a compromised host could exfiltrate to the Internet. Restricting outbound is PROPOSED.
- Validation is configuration-based (no VMs).
