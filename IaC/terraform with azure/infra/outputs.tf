output "resource_group_name" {
  description = "Name of the created Resource Group."
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = module.networking.vnet_name
}

output "subnet_id" {
  description = "Resource ID of the default subnet."
  value       = module.networking.subnet_id
}

output "nsg_id" {
  description = "Resource ID of the Network Security Group."
  value       = module.security.nsg_id
}
