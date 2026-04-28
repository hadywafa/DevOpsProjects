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
  description = "Azure region for all resources."
  default     = "eastus"
}

variable "project_name" {
  type        = string
  description = "Short project identifier used in resource names (lowercase, ≤10 chars)."
  default     = "tfdemo"
  validation {
    condition     = length(var.project_name) <= 10 && can(regex("^[a-z0-9]+$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric and ≤10 chars."
  }
}

variable "vnet_address_space" {
  type        = list(string)
  description = "CIDR block(s) for the Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  type        = string
  description = "CIDR block for the default subnet."
  default     = "10.0.1.0/24"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged with default tags."
  default     = {}
}
