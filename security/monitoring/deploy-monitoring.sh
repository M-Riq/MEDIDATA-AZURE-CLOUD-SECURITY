#!/usr/bin/env bash
# Recreates monitoring for Exam Part 2.2. Requires RG, LOC, SA, KV, VNET and EMAIL.
set -euo pipefail
RG="${RG:?}"; LOC="${LOC:-francecentral}"; SA="${SA:?}"; KV="${KV:?}"; VNET="${VNET:?}"; EMAIL="${EMAIL:?}"
LAW="law-medidata-bryan"
TAGS="Project=MediData Environment=Academic-Lab DataClassification=Synthetic-PHI ExamPart=2.2 ManagedBy=AzureCLI"

for P in Microsoft.Security Microsoft.Insights Microsoft.OperationalInsights; do az provider register -n "$P" --wait; done

az monitor log-analytics workspace create -g "$RG" -n "$LAW" -l "$LOC" --sku PerGB2018 --retention-time 30 --tags $TAGS -o none
LAWID=$(az monitor log-analytics workspace show -g "$RG" -n "$LAW" --query id -o tsv)

SAID=$(az storage account show -g "$RG" -n "$SA" --query id -o tsv)
KVID=$(az keyvault show -n "$KV" --query id -o tsv)
VNETID=$(az network vnet show -g "$RG" -n "$VNET" --query id -o tsv)
NSGIDS=$(az network nsg list -g "$RG" --query "[].id" -o tsv)
LOGS='[{"categoryGroup":"allLogs","enabled":true}]'
METRICS='[{"category":"AllMetrics","enabled":true}]'
TX='[{"category":"Transaction","enabled":true}]'

az monitor diagnostic-settings create -n diag-to-law --resource "$VNETID" --workspace "$LAWID" --logs "$LOGS" --metrics "$METRICS" -o none
for N in $NSGIDS; do az monitor diagnostic-settings create -n diag-to-law --resource "$N" --workspace "$LAWID" --logs "$LOGS" -o none; done
az monitor diagnostic-settings create -n diag-to-law --resource "$SAID" --workspace "$LAWID" --metrics "$TX" -o none
az monitor diagnostic-settings create -n diag-to-law --resource "$SAID/blobServices/default" --workspace "$LAWID" --logs "$LOGS" --metrics "$TX" -o none
az monitor diagnostic-settings create -n diag-to-law --resource "$KVID" --workspace "$LAWID" --logs "$LOGS" --metrics "$METRICS" -o none
az monitor diagnostic-settings subscription create -n diag-activity-to-law -l "$LOC" --workspace "$LAWID" \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"Policy","enabled":true},{"category":"Alert","enabled":true}]' -o none

az monitor action-group create -g "$RG" -n ag-medidata-security --short-name MediSecOps --action email secops-email "$EMAIL" --tags $TAGS -o none
AGID=$(az monitor action-group show -g "$RG" -n ag-medidata-security --query id -o tsv)

az monitor scheduled-query create -g "$RG" -n alert-kv-excessive-auth-failures --scopes "$LAWID" \
  --condition "count 'Failures' > 5" \
  --condition-query Failures="AzureDiagnostics | where ResourceProvider == 'MICROSOFT.KEYVAULT' | where httpStatusCode_d in (401, 403)" \
  --evaluation-frequency 15m --window-size 15m --severity 1 --action-groups "$AGID" \
  --description "Security: more than 5 denied Key Vault requests in 15 min" --tags $TAGS -o none
echo "Monitoring deployed"
