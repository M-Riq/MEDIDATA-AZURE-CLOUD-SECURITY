#!/usr/bin/env bash
# Phase A: READ-ONLY environment verification.
# This script creates, registers, and modifies NOTHING.
# Usage: az login && bash phase-a-verify.sh <region>   (e.g. eastus)
set -euo pipefail
REGION="${1:-eastus}"

echo "== 1. Signed-in account and active subscription =="
az account show --query "{subscription:name, state:state, user:user.type, isDefault:isDefault}" -o table

echo "== 2. All subscriptions visible to you =="
az account list --query "[].{name:name, state:state}" -o table

echo "== 3. Your role assignments (need Owner or User Access Administrator for custom roles) =="
ME=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || echo "")
if [ -n "$ME" ]; then
  az role assignment list --assignee "$ME" --all --query "[].{role:roleDefinitionName, scope:scope}" -o table
else
  echo "Could not read your Entra ID object (tenant may restrict Graph access). Check IAM in the portal."
fi

echo "== 4. Resource provider registration state =="
for p in Microsoft.Network Microsoft.Storage Microsoft.KeyVault Microsoft.OperationalInsights \
         Microsoft.Insights Microsoft.Security Microsoft.PolicyInsights Microsoft.ManagedIdentity; do
  printf "%-32s %s\n" "$p" "$(az provider show -n "$p" --query registrationState -o tsv)"
done

echo "== 5. Network quotas in $REGION =="
az network list-usages --location "$REGION" \
  --query "[?contains(name.value,'VirtualNetworks') || contains(name.value,'NetworkSecurityGroups')].{name:name.localizedValue, used:currentValue, limit:limit}" -o table

echo "== 6. Allowed-locations policies affecting you (student offers often restrict regions) =="
az policy assignment list --query "[].{name:displayName, scope:scope}" -o table || true

echo "Done. Nothing was changed."
