variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "kubernetes_version" { type = string; default = "1.30" }
variable "system_node_vm_size" { type = string; default = "Standard_D2s_v3" }
variable "user_node_vm_size" { type = string; default = "Standard_D2s_v3" }
variable "system_node_count_min" { type = number; default = 1 }
variable "system_node_count_max" { type = number; default = 3 }
variable "user_node_count_min" { type = number; default = 1 }
variable "user_node_count_max" { type = number; default = 5 }
variable "user_assigned_identity_id" { type = string }
variable "tags" { type = map(string); default = {} }
