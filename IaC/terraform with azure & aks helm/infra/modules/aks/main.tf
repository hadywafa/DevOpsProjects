resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = "${var.project_name}-${var.environment}"
  tags                = var.tags

  # System node pool: runs kube-system workloads (coredns, metrics-server, etc.)
  default_node_pool {
    name                = "system"
    vm_size             = var.system_node_vm_size
    min_count           = var.system_node_count_min
    max_count           = var.system_node_count_max
    enable_auto_scaling = true
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    node_labels = {
      "agentpool" = "system"
    }
    # Taint system pool so user workloads don't land here
    node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
  }

  # Use the pre-created user-assigned identity (avoids needing Owner on RG)
  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  # Workload Identity + OIDC: allows pods to authenticate to Azure AD without secrets
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  # Azure Monitor integration for container insights
  monitor_metrics {}

  # Network profile: Azure CNI gives pods real VNet IPs (production-grade)
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  # Azure RBAC for Kubernetes: use Azure AD groups instead of kubeconfig certs for access
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,  # managed by autoscaler
    ]
  }
}

# User node pool: separate pool for application workloads
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.user_node_vm_size
  min_count             = var.user_node_count_min
  max_count             = var.user_node_count_max
  enable_auto_scaling   = true
  os_disk_size_gb       = 128
  tags                  = var.tags

  node_labels = {
    "agentpool" = "user"
    "workload"  = "application"
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}
