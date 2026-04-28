# The helm and kubernetes providers are configured using kubeconfig data
# fetched directly from Azure via a data source — no kubeconfig file is
# written to disk or stored as a pipeline artifact.
#
# depends_on on the data source ensures the AKS cluster is fully created
# before Terraform tries to configure these providers.

data "azurerm_kubernetes_cluster" "aks" {
  name                = module.aks.cluster_name
  resource_group_name = module.aks.resource_group_name
  depends_on          = [module.aks]
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}
