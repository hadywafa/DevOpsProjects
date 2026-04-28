#!/usr/bin/env bash
# Creates a Service Principal for ARM deployments and assigns least-privilege roles.
# Run this ONCE per environment before first deployment.
#
# Usage: ./create-service-principal.sh <subscription-id> <environment> [location]
# Example: ./create-service-principal.sh 00000000-0000-0000-0000-000000000000 dev eastus

set -euo pipefail

SUBSCRIPTION_ID="${1:?Usage: $0 <subscription-id> <environment> [location]}"
ENVIRONMENT="${2:?Usage: $0 <subscription-id> <environment> [location]}"
LOCATION="${3:-eastus}"
PROJECT_NAME="armdemo"
SP_NAME="sp-arm-${PROJECT_NAME}-${ENVIRONMENT}"
RG_NAME="rg-${PROJECT_NAME}-${ENVIRONMENT}-${LOCATION}"

echo "==> Logging in and setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

echo "==> Creating Service Principal: $SP_NAME"
SP_JSON=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --skip-assignment \
  --output json)

SP_APP_ID=$(echo "$SP_JSON" | jq -r '.appId')
SP_PASSWORD=$(echo "$SP_JSON" | jq -r '.password')
SP_TENANT=$(echo "$SP_JSON" | jq -r '.tenant')

echo "   App ID:  $SP_APP_ID"
echo "   Tenant:  $SP_TENANT"

# --- Role: Resource Group Contributor at subscription scope (to create the RG) ---
echo "==> Assigning 'Contributor' at subscription scope for RG creation..."
az role assignment create \
  --assignee "$SP_APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --output none

# Scope down after first deploy: replace subscription-scope Contributor with RG-scope Contributor
# az role assignment delete --assignee "$SP_APP_ID" --role "Contributor" --scope "/subscriptions/$SUBSCRIPTION_ID"
# az role assignment create --assignee "$SP_APP_ID" --role "Contributor" \
#   --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME"

echo ""
echo "=== Save these values in Azure DevOps Library (variable group: iac-arm-azure-secrets) ==="
echo "AZURE_CLIENT_ID:       $SP_APP_ID"
echo "AZURE_CLIENT_SECRET:   $SP_PASSWORD"
echo "AZURE_TENANT_ID:       $SP_TENANT"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo ""
echo "=== For Azure DevOps Service Connection ==="
echo "Connection type: Azure Resource Manager > Service Principal (manual)"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Service Principal ID: $SP_APP_ID"
echo "Service Principal Key: <the password above>"
echo "Tenant ID: $SP_TENANT"
echo "Service connection name: sc-arm-azure-$ENVIRONMENT"
