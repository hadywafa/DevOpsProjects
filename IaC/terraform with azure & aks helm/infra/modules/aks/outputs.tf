output "cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "cluster_fqdn" {
  value = azurerm_kubernetes_cluster.main.fqdn
}

output "resource_group_name" {
  value = azurerm_kubernetes_cluster.main.resource_group_name
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL — used to configure workload identity federation."
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}
