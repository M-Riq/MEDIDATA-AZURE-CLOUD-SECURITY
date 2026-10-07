#!/usr/bin/env bash
# Recreates Phase G (Exam Part 3.1). Requires RG, LOC, VNET, SA, KV, LAW.
set -euo pipefail
RG="${RG:?}"; LOC="${LOC:-francecentral}"; VNET="${VNET:?}"; SA="${SA:?}"; KV="${KV:?}"; LAW="${LAW:?}"
RGID=$(az group show -n "$RG" --query id -o tsv)

# G-1: HITRUST/HIPAA initiative, audit only. Pass the NAME (full ID triggers a CLI bug).
az policy assignment create -n medidata-hipaa-hitrust \
  --display-name "MediData - HITRUST/HIPAA (audit)" \
  --policy-set-definition a169a624-5599-4385-a696-c8d643089fab \
  --scope "$RGID" --enforcement-mode DoNotEnforce \
  --mi-system-assigned --location "$LOC" -o none

# G-3a: Key Vault audit logging with named categories
KVID=$(az keyvault show -n "$KV" --query id -o tsv)
LAWID=$(az monitor log-analytics workspace show -g "$RG" -n "$LAW" --query id -o tsv)
az monitor diagnostic-settings create -n diag-to-law --resource "$KVID" --workspace "$LAWID" \
  --logs '[{"category":"AuditEvent","enabled":true},{"category":"AzurePolicyEvaluationDetails","enabled":true}]' \
  --metrics '[{"category":"AllMetrics","enabled":true}]' -o none

# G-3b: network isolation
az network vnet subnet update -g "$RG" --vnet-name "$VNET" -n Data-Subnet \
  --service-endpoints Microsoft.KeyVault Microsoft.Storage -o none
SUBID=$(az network vnet subnet show -g "$RG" --vnet-name "$VNET" -n Data-Subnet --query id -o tsv)
[ -n "$SUBID" ] || { echo "SUBID empty"; exit 1; }
az storage account network-rule add -g "$RG" --account-name "$SA" --subnet "$SUBID" -o none
az storage account update -g "$RG" -n "$SA" --default-action Deny --bypass AzureServices -o none
az keyvault network-rule add -n "$KV" --subnet "$SUBID" -o none
az keyvault update -n "$KV" --default-action Deny --bypass AzureServices -o none

az policy state trigger-scan -g "$RG" --no-wait
echo "Compliance deployed; results in ~30 min"

# Temporary admin/demo access to Key Vault data plane:
# MYIP=$(curl -s https://api.ipify.org)
# az keyvault network-rule add -n "$KV" --ip-address "$MYIP/32"
# az keyvault network-rule remove -n "$KV" --ip-address "$MYIP/32"
