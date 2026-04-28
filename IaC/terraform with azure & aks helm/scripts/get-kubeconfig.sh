#!/usr/bin/env bash
# Retrieves kubeconfig for the AKS cluster after Terraform deployment.
# Use this for local kubectl/helm access.
#
# Usage: ./get-kubeconfig.sh <environment> [--admin]
# Example: ./get-kubeconfig.sh dev

set -euo pipefail

ENVIRONMENT="${1:?Arg 1: environment}"
ADMIN_FLAG="${2:-}"

PROJECT_NAME="aksdemo"
RG_NAME="rg-${PROJECT_NAME}-${ENVIRONMENT}-eastus"
CLUSTER_NAME="aks-${PROJECT_NAME}-${ENVIRONMENT}"

echo "==> Fetching kubeconfig for: $CLUSTER_NAME (RG: $RG_NAME)"

if [ "$ADMIN_FLAG" = "--admin" ]; then
  echo "   WARNING: --admin mode grants full cluster-admin. Use only for break-glass scenarios."
  az aks get-credentials \
    --resource-group "$RG_NAME" \
    --name "$CLUSTER_NAME" \
    --overwrite-existing \
    --admin
else
  # Normal access uses Azure AD integration — users authenticate with their own identity
  az aks get-credentials \
    --resource-group "$RG_NAME" \
    --name "$CLUSTER_NAME" \
    --overwrite-existing
fi

echo "==> Verifying cluster access..."
kubectl get nodes
echo ""
echo "==> Helm releases:"
helm list -A
