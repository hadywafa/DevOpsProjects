environment                 = "prod"
location                    = "eastus"
project_name                = "aksdemo"
kubernetes_version          = "1.30"
system_node_vm_size         = "Standard_D4s_v3"
user_node_vm_size           = "Standard_D4s_v3"
system_node_count_min       = 2
system_node_count_max       = 5
user_node_count_min         = 2
user_node_count_max         = 10
nginx_ingress_chart_version = "4.10.1"
cert_manager_chart_version  = "1.15.1"
tags = {
  owner       = "platform-team"
  cost-center = "engineering"
}
