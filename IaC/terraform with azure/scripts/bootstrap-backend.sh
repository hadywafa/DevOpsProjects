#!/usr/bin/env bash
# Creates the Azure Storage Account used as Terraform remote backend.
# Run this ONCE before the first `terraform init`.
#
# Usage: ./bootstrap-backend.sh <subscription-id> <environment> [location]
# Example: ./bootstrap-backend.sh 00000000-... dev eastus

set -euo pipefail

SUBSCRIPTION_ID="${1:?Arg 1: subscription-id}"
ENVIRONMENT="${2:?Arg 2: environment}"
LOCATION="${3:-eastus}"

BACKEND_RG="rg-tfstate-${ENVIRONMENT}-${LOCATION}"
BACKEND_SA="sttfstate${ENVIRONMENT}$(echo "$SUBSCRIPTION_ID" | tr -d '-' | cut -c1-8)"
BACKEND_CONTAINER="tfstate"

echo "==> Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

echo "==> Creating backend Resource Group: $BACKEND_RG"
az group create \
  --name "$BACKEND_RG" \
  --location "$LOCATION" \
  --tags "environment=$ENVIRONMENT" "managed-by=bootstrap-script" \
  --output none

echo "==> Creating Storage Account: $BACKEND_SA"
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

echo "==> Enabling versioning on the storage account (state file history)..."
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
echo "=== Backend created. Use these values in terraform init and ADO variable group ==="
echo "BACKEND_RG:        $BACKEND_RG"
echo "BACKEND_SA_NAME:   $BACKEND_SA"
echo "BACKEND_CONTAINER: $BACKEND_CONTAINER"
echo ""
echo "=== Example terraform init command ==="
echo "terraform init \\"
echo "  -backend-config=\"storage_account_name=$BACKEND_SA\" \\"
echo "  -backend-config=\"container_name=$BACKEND_CONTAINER\" \\"
echo "  -backend-config=\"key=networking/$ENVIRONMENT.tfstate\" \\"
echo "  -backend-config=\"resource_group_name=$BACKEND_RG\""
