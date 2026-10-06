#!/usr/bin/env bash
# Recreates storage + Key Vault CMK + rotation policy (Exam Part 2.1).
set -euo pipefail

RG="${RG:?set RG}"; LOC="${LOC:-francecentral}"
SA="${SA:?set SA (globally unique)}"; KV="${KV:?set KV (globally unique)}"; KEY="${KEY:-cmk-medidata-storage}"
TAGS="Project=MediData Environment=Academic-Lab DataClassification=Synthetic-PHI ExamPart=2.1 ManagedBy=AzureCLI"

az storage account create -g "$RG" -n "$SA" -l "$LOC" --sku Standard_LRS --kind StorageV2 \
  --https-only true --min-tls-version TLS1_2 --allow-blob-public-access false \
  --allow-shared-key-access false --default-action Deny --bypass AzureServices \
  --assign-identity --tags $TAGS -o none

az keyvault create -g "$RG" -n "$KV" -l "$LOC" --sku standard --enable-rbac-authorization true \
  --enable-purge-protection true --retention-days 7 --tags $TAGS -o none

KVID=$(az keyvault show -n "$KV" --query id -o tsv)
ME=$(az ad signed-in-user show --query id -o tsv)
az role assignment create --assignee-object-id "$ME" --assignee-principal-type User \
  --role "Key Vault Crypto Officer" --scope "$KVID" -o none
echo "Waiting for RBAC propagation..."; sleep 180

az keyvault key create --vault-name "$KV" -n "$KEY" --kty RSA --size 3072 --ops wrapKey unwrapKey -o none

SAPID=$(az storage account show -g "$RG" -n "$SA" --query identity.principalId -o tsv)
az role assignment create --assignee-object-id "$SAPID" --assignee-principal-type ServicePrincipal \
  --role "Key Vault Crypto Service Encryption User" --scope "$KVID/keys/$KEY" -o none
sleep 180

az storage account update -g "$RG" -n "$SA" --encryption-key-source Microsoft.Keyvault \
  --encryption-key-vault "$(az keyvault show -n "$KV" --query properties.vaultUri -o tsv)" \
  --encryption-key-name "$KEY" -o none

az keyvault key rotation-policy update --vault-name "$KV" -n "$KEY" \
  --value "$(dirname "$0")/rotation-policy.json" -o none
echo "Encryption deployed"
