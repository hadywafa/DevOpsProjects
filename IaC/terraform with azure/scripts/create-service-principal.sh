#!/usr/bin/env bash
# Creates a Service Principal for Terraform Azure deployments with least-privilege roles.
# Run this ONCE per environment after running bootstrap-backend.sh.
#
# Usage: ./create-service-principal.sh <subscription-id> <environment> <backend-rg> <backend-sa>
# Example:
#   ./create-service-principal.sh 00000000-... dev rg-tfstate-dev-eastus stftstatedev12345678

set -euo pipefail

SUBSCRIPTION_ID="${1:?Arg 1: subscription-id}"
ENVIRONMENT="${2:?Arg 2: environment}"
BACKEND_RG="${3:?Arg 3: backend resource group name}"
BACKEND_SA="${4:?Arg 4: backend storage account name}"

PROJECT_NAME="tfdemo"
SP_NAME="sp-tf-azure-${PROJECT_NAME}-${ENVIRONMENT}"
TARGET_RG="rg-${PROJECT_NAME}-${ENVIRONMENT}-eastus"

echo "==> Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

echo "==> Creating Service Principal: $SP_NAME"
SP_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --skip-assignment \
  --output json)

SP_APP_ID=$(echo "$SP_JSON" | jq -r '.appId')
SP_PASSWORD=$(echo "$SP_JSON" | jq -r '.password')
SP_TENANT=$(echo "$SP_JSON" | jq -r '.tenant')

echo "   App ID: $SP_APP_ID"

# Role 1: Network Contributor on target RG (for VNet, Subnet, NSG)
# We pre-create the RG so we can scope the SP to it from the start
echo "==> Creating target resource group: $TARGET_RG (if not exists)"
az group create \
  --name "$TARGET_RG" \
  --location eastus \
  --output none 2>/dev/null || true

echo "==> Assigning 'Network Contributor' on target RG..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "Network Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TARGET_RG" \
  --output none

# Also need Contributor on RG to create/delete the RG itself in Terraform
echo "==> Assigning 'Contributor' on target RG (for RG lifecycle)..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TARGET_RG" \
  --output none

# Role 2: Storage Blob Data Contributor on backend storage (for TF state)
echo "==> Assigning 'Storage Blob Data Contributor' on backend storage..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$BACKEND_RG/providers/Microsoft.Storage/storageAccounts/$BACKEND_SA" \
  --output none

echo ""
echo "=== Export these for local Terraform runs ==="
echo "export ARM_CLIENT_ID=\"$SP_APP_ID\""
echo "export ARM_CLIENT_SECRET=\"$SP_PASSWORD\""
echo "export ARM_TENANT_ID=\"$SP_TENANT\""
echo "export ARM_SUBSCRIPTION_ID=\"$SUBSCRIPTION_ID\""
echo ""
echo "=== ADO Library variable group: iac-tf-azure-backend ==="
echo "BACKEND_SA_NAME:   $BACKEND_SA"
echo "BACKEND_RG:        $BACKEND_RG"
echo "BACKEND_CONTAINER: tfstate"
echo ""
echo "=== ADO Service Connection ==="
echo "Name:              sc-tf-azure-$ENVIRONMENT"
echo "Type:              Azure Resource Manager > Service Principal (manual)"
echo "Client ID:         $SP_APP_ID"
echo "Client Secret:     $SP_PASSWORD"
echo "Tenant ID:         $SP_TENANT"
echo "Subscription ID:   $SUBSCRIPTION_ID"
