#!/usr/bin/env bash
# Recreates the MediData segmented network (Exam Part 1.2). Free resources only.
set -euo pipefail

RG="${RG:?set RG, e.g. MediData-Project-A-<LastName>}"
LOC="${LOC:-francecentral}"
VNET="${VNET:-vnet-medidata-a}"
TAGS="Project=MediData Environment=Academic-Lab DataClassification=Synthetic-PHI ExamPart=1.2 ManagedBy=AzureCLI"

az network vnet create -g "$RG" -n "$VNET" -l "$LOC" --address-prefixes 10.10.0.0/16 \
  --subnet-name Web-Subnet --subnet-prefixes 10.10.1.0/24 --tags $TAGS -o none
az network vnet subnet create -g "$RG" --vnet-name "$VNET" -n App-Subnet  --address-prefixes 10.10.2.0/24 -o none
az network vnet subnet create -g "$RG" --vnet-name "$VNET" -n Data-Subnet --address-prefixes 10.10.3.0/24 -o none

for N in nsg-web-subnet nsg-app-subnet nsg-data-subnet; do
  az network nsg create -g "$RG" -n "$N" -l "$LOC" --tags $TAGS -o none
done

allow() { # nsg name source dest ports...
  local nsg=$1 name=$2 src=$3 dst=$4; shift 4
  az network nsg rule create -g "$RG" --nsg-name "$nsg" -n "$name" --priority 100 \
    --direction Inbound --access Allow --protocol Tcp \
    --source-address-prefixes "$src" --source-port-ranges '*' \
    --destination-address-prefixes "$dst" --destination-port-ranges "$@" -o none
}
allow nsg-web-subnet  Allow-HTTP-HTTPS-Internet Internet     10.10.1.0/24 80 443
allow nsg-app-subnet  Allow-8080-From-Web       10.10.1.0/24 10.10.2.0/24 8080
allow nsg-data-subnet Allow-1433-From-App       10.10.2.0/24 10.10.3.0/24 1433

for N in nsg-web-subnet nsg-app-subnet nsg-data-subnet; do
  az network nsg rule create -g "$RG" --nsg-name "$N" -n Deny-All-Inbound --priority 4096 \
    --direction Inbound --access Deny --protocol '*' --source-address-prefixes '*' \
    --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges '*' -o none
done

az network vnet subnet update -g "$RG" --vnet-name "$VNET" -n Web-Subnet  --network-security-group nsg-web-subnet  -o none
az network vnet subnet update -g "$RG" --vnet-name "$VNET" -n App-Subnet  --network-security-group nsg-app-subnet  -o none
az network vnet subnet update -g "$RG" --vnet-name "$VNET" -n Data-Subnet --network-security-group nsg-data-subnet -o none
echo "Network deployed"
