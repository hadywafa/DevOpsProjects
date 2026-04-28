#!/usr/bin/env bash
# Creates a Service Principal with OIDC (Workload Identity Federation) for Bicep deployments.
# No client secret is generated — the most secure pattern for Azure DevOps CI.
#
# Usage: ./create-service-principal.sh <subscription-id> <environment> <ado-org> <ado-project> <ado-service-connection-name>
# Example:
#   ./create-service-principal.sh 00000000-... dev MyOrg MyProject sc-bicep-oidc-dev

set -euo pipefail

SUBSCRIPTION_ID="${1:?Arg 1: subscription-id}"
ENVIRONMENT="${2:?Arg 2: environment (dev|prod)}"
ADO_ORG="${3:?Arg 3: Azure DevOps org name}"
ADO_PROJECT="${4:?Arg 4: Azure DevOps project name}"
SC_NAME="${5:?Arg 5: Service connection name (e.g. sc-bicep-oidc-dev)}"

PROJECT_NAME="bicepdemo"
SP_NAME="sp-bicep-${PROJECT_NAME}-${ENVIRONMENT}"
RG_NAME="rg-${PROJECT_NAME}-${ENVIRONMENT}-eastus"

echo "==> Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Retrieve the ADO org ID (needed for OIDC issuer URL)
echo "==> Fetching ADO org ID for OIDC issuer..."
ADO_ORG_ID=$(az devops invoke \
  --area core --resource accounts \
  --query "value[?accountName=='$ADO_ORG'].accountId | [0]" \
  --output tsv 2>/dev/null || echo "UNKNOWN")

echo "==> Creating App Registration (no secret): $SP_NAME"
APP_JSON=$(az ad app create --display-name "$SP_NAME" --output json)
APP_ID=$(echo "$APP_JSON" | jq -r '.appId')
OBJECT_ID=$(echo "$APP_JSON" | jq -r '.id')

echo "==> Creating Service Principal for the App..."
az ad sp create --id "$APP_ID" --output none

echo "==> Adding federated credential for Azure DevOps service connection..."
# Subject format: sc://<org>/<project>/<service-connection-name>
az ad app federated-credential create \
  --id "$OBJECT_ID" \
  --parameters "{
    \"name\": \"ado-${ENVIRONMENT}-sc\",
    \"issuer\": \"https://vstoken.dev.azure.com/${ADO_ORG_ID}\",
    \"subject\": \"sc://${ADO_ORG}/${ADO_PROJECT}/${SC_NAME}\",
    \"description\": \"OIDC for ADO service connection ${SC_NAME}\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }" \
  --output none

echo "==> Assigning Contributor on subscription (for RG creation)..."
az role assignment create \
  --assignee "$APP_ID" \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --output none

echo ""
echo "=== Register this in Azure DevOps ==="
echo "Service Connection type: Azure Resource Manager > Workload Identity Federation (manual)"
echo "Subscription ID:         $SUBSCRIPTION_ID"
echo "Client ID (App ID):      $APP_ID"
echo "Tenant ID:               $(az account show --query tenantId -o tsv)"
echo "Service connection name: $SC_NAME"
echo ""
echo "NOTE: No secret needed — authentication uses OIDC token exchange."
