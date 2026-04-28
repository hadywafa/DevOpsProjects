environment                 = "dev"
location                    = "eastus"
project_name                = "aksdemo"
kubernetes_version          = "1.30"
system_node_vm_size         = "Standard_D2s_v3"
user_node_vm_size           = "Standard_D2s_v3"
system_node_count_min       = 1
system_node_count_max       = 3
user_node_count_min         = 1
user_node_count_max         = 3
nginx_ingress_chart_version = "4.10.1"
cert_manager_chart_version  = "1.15.1"
tags = {
  owner       = "platform-team"
  cost-center = "engineering"
}
