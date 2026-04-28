#!/usr/bin/env bash
# Creates the Azure Storage Account used as Terraform remote backend for the AKS project.
# Run this ONCE before the first `terraform init`.
#
# Usage: ./bootstrap-backend.sh <subscription-id> <environment> [location]

set -euo pipefail

SUBSCRIPTION_ID="${1:?Arg 1: subscription-id}"
ENVIRONMENT="${2:?Arg 2: environment}"
LOCATION="${3:-eastus}"

BACKEND_RG="rg-tfstate-aks-${ENVIRONMENT}-${LOCATION}"
BACKEND_SA="sttfstateaks${ENVIRONMENT}$(echo "$SUBSCRIPTION_ID" | tr -d '-' | cut -c1-6)"
BACKEND_CONTAINER="tfstate"

az account set --subscription "$SUBSCRIPTION_ID"

echo "==> Creating backend RG: $BACKEND_RG"
az group create --name "$BACKEND_RG" --location "$LOCATION" --output none

echo "==> Creating storage account: $BACKEND_SA"
az storage account create \
  --name "$BACKEND_SA" \
  --resource-group "$BACKEND_RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --https-only true \
  --output none

az storage account blob-service-properties update \
  --account-name "$BACKEND_SA" \
  --resource-group "$BACKEND_RG" \
  --enable-versioning true \
  --output none

echo "==> Creating container: $BACKEND_CONTAINER"
az storage container create \
  --name "$BACKEND_CONTAINER" \
  --account-name "$BACKEND_SA" \
  --auth-mode login \
  --output none

echo ""
echo "=== ADO variable group: iac-aks-azure-backend ==="
echo "BACKEND_SA_NAME:   $BACKEND_SA"
echo "BACKEND_RG:        $BACKEND_RG"
echo "BACKEND_CONTAINER: $BACKEND_CONTAINER"
