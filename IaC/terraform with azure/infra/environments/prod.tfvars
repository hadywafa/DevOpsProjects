environment           = "prod"
location              = "eastus"
project_name          = "tfdemo"
vnet_address_space    = ["10.1.0.0/16"]
subnet_address_prefix = "10.1.1.0/24"
tags = {
  owner       = "platform-team"
  cost-center = "engineering"
}
