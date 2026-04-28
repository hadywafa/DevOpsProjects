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

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  type    = string
  default = "10.0.1.0/24"
}

variable "tags" {
  type    = map(string)
  default = {}
}
