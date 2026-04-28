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

module "networking" {
  source = "./modules/networking"

  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  project_name          = var.project_name
  environment           = var.environment
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
  tags                  = local.tags
}

module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project_name        = var.project_name
  environment         = var.environment
  subnet_id           = module.networking.subnet_id
  tags                = local.tags
}
