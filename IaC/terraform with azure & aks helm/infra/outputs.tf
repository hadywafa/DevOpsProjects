output "resource_group_name" {
  description = "Name of the AKS Resource Group."
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.cluster_id
}

output "cluster_fqdn" {
  description = "FQDN of the AKS API server."
  value       = module.aks.cluster_fqdn
}

output "kube_config" {
  description = "Raw kubeconfig — marked sensitive, not printed by default."
  value       = module.aks.kube_config_raw
  sensitive   = true
}

output "nginx_ingress_namespace" {
  description = "Namespace where nginx-ingress is installed."
  value       = module.helm_releases.nginx_ingress_namespace
}

output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed."
  value       = module.helm_releases.cert_manager_namespace
}
