# Partial backend configuration — values are supplied at `terraform init` time
# via -backend-config flags or environment variables. This avoids hardcoding
# storage account names and enables reuse across environments.
#
# Init command:
#   terraform init \
#     -backend-config="storage_account_name=<BACKEND_SA>" \
#     -backend-config="container_name=tfstate" \
#     -backend-config="key=networking/<environment>.tfstate" \
#     -backend-config="resource_group_name=<BACKEND_RG>"

terraform {
  backend "azurerm" {
    # All values injected at init time — nothing hardcoded here.
  }
}
