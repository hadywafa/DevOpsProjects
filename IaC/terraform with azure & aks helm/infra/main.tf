locals {
  resource_group_name = "rg-${var.project_name}-${var.environment}-${var.location}"
  default_tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
  tags = merge(local.default_tags, var.tags)
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# User-assigned managed identity for AKS — created before the cluster
# so we can assign roles to it before cluster creation (avoids Owner on RG).
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.project_name}-${var.environment}-aks"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags
}

module "aks" {
  source = "./modules/aks"

  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  project_name              = var.project_name
  environment               = var.environment
  kubernetes_version        = var.kubernetes_version
  system_node_vm_size       = var.system_node_vm_size
  user_node_vm_size         = var.user_node_vm_size
  system_node_count_min     = var.system_node_count_min
  system_node_count_max     = var.system_node_count_max
  user_node_count_min       = var.user_node_count_min
  user_node_count_max       = var.user_node_count_max
  user_assigned_identity_id = azurerm_user_assigned_identity.aks.id
  tags                      = local.tags
}

module "helm_releases" {
  source = "./modules/helm-releases"

  nginx_ingress_chart_version = var.nginx_ingress_chart_version
  cert_manager_chart_version  = var.cert_manager_chart_version

  depends_on = [module.aks]
}
