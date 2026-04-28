variable "environment" {
  type        = string
  description = "Deployment environment (dev or prod)."
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "eastus"
}

variable "project_name" {
  type        = string
  description = "Short project identifier (lowercase, ≤8 chars)."
  default     = "aksdemo"
}

variable "kubernetes_version" {
  type        = string
  description = "AKS Kubernetes version (e.g. '1.30')."
  default     = "1.30"
}

variable "system_node_vm_size" {
  type        = string
  description = "VM size for the system node pool."
  default     = "Standard_D2s_v3"
}

variable "user_node_vm_size" {
  type        = string
  description = "VM size for the user node pool."
  default     = "Standard_D2s_v3"
}

variable "system_node_count_min" {
  type        = number
  description = "Minimum nodes in the system pool."
  default     = 1
}

variable "system_node_count_max" {
  type        = number
  description = "Maximum nodes in the system pool."
  default     = 3
}

variable "user_node_count_min" {
  type        = number
  description = "Minimum nodes in the user pool."
  default     = 1
}

variable "user_node_count_max" {
  type        = number
  description = "Maximum nodes in the user pool."
  default     = 5
}

variable "nginx_ingress_chart_version" {
  type        = string
  description = "nginx-ingress Helm chart version to install."
  default     = "4.10.1"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "cert-manager Helm chart version to install."
  default     = "1.15.1"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged with defaults."
  default     = {}
}
