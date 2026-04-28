#!/usr/bin/env bash
# Creates a Service Principal for AKS Terraform deployments.
# This SP provisions both the infrastructure (AKS) AND the user-assigned managed identity.
#
# Usage: ./create-service-principal.sh <subscription-id> <environment> <backend-rg> <backend-sa>

set -euo pipefail

SUBSCRIPTION_ID="${1:?Arg 1: subscription-id}"
ENVIRONMENT="${2:?Arg 2: environment}"
BACKEND_RG="${3:?Arg 3: backend resource group}"
BACKEND_SA="${4:?Arg 4: backend storage account}"

PROJECT_NAME="aksdemo"
SP_NAME="sp-tf-aks-${PROJECT_NAME}-${ENVIRONMENT}"
TARGET_RG="rg-${PROJECT_NAME}-${ENVIRONMENT}-eastus"

az account set --subscription "$SUBSCRIPTION_ID"

echo "==> Creating SP: $SP_NAME"
SP_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --skip-assignment \
  --output json)

SP_APP_ID=$(echo "$SP_JSON" | jq -r '.appId')
SP_PASSWORD=$(echo "$SP_JSON" | jq -r '.password')
SP_TENANT=$(echo "$SP_JSON" | jq -r '.tenant')

# Pre-create target RG so we can scope SP to it
az group create --name "$TARGET_RG" --location eastus --output none 2>/dev/null || true

echo "==> Assigning 'Contributor' on target RG (for AKS, VNet, managed identity creation)..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TARGET_RG" \
  --output none

# Managed Identity Operator: allows SP to assign the user-assigned identity to AKS
echo "==> Assigning 'Managed Identity Operator' on target RG..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "Managed Identity Operator" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TARGET_RG" \
  --output none

# Storage Blob Data Contributor on backend
echo "==> Assigning 'Storage Blob Data Contributor' on backend storage..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$BACKEND_RG/providers/Microsoft.Storage/storageAccounts/$BACKEND_SA" \
  --output none

echo ""
echo "=== Export for local Terraform runs ==="
echo "export ARM_CLIENT_ID=\"$SP_APP_ID\""
echo "export ARM_CLIENT_SECRET=\"$SP_PASSWORD\""
echo "export ARM_TENANT_ID=\"$SP_TENANT\""
echo "export ARM_SUBSCRIPTION_ID=\"$SUBSCRIPTION_ID\""
echo ""
echo "=== ADO Service Connection: sc-aks-azure-$ENVIRONMENT ==="
echo "Client ID: $SP_APP_ID | Tenant: $SP_TENANT | Sub: $SUBSCRIPTION_ID"
