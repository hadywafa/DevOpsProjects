# Partial backend configuration — values supplied at `terraform init` time.
#
# Init command:
#   terraform init \
#     -backend-config="storage_account_name=<BACKEND_SA>" \
#     -backend-config="container_name=<BACKEND_CONTAINER>" \
#     -backend-config="key=aks/<environment>.tfstate" \
#     -backend-config="resource_group_name=<BACKEND_RG>"

terraform {
  backend "azurerm" {}
}
