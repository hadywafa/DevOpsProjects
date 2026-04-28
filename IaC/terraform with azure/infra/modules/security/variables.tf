variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet to associate the NSG with."
}

variable "tags" {
  type    = map(string)
  default = {}
}
