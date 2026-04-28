variable "nginx_ingress_chart_version" {
  type        = string
  description = "nginx-ingress Helm chart version."
  default     = "4.10.1"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "cert-manager Helm chart version."
  default     = "1.15.1"
}
