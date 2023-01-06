provider "azurerm" {
  features {}

  skip_provider_registration = true
}

#using Existing RG. Due to permission issues.
data "azurerm_resource_group" "rg" {
  name = var.rg-name
}

#Zones not available in all the regions
variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

module "networking" {
  source          = "./modules/networking"
  rg-name         = var.rg-name
  project_name    = var.project_name
  vnet_cidr       = var.vnet_cidr
  web_subnet_cidr = var.web_subnet_cidr
  app_subnet_cidr = var.app_subnet_cidr
  db_subnet_cidr  = var.db_subnet_cidr
  vm_size         = var.vm_size
  user            = var.user
  password        = var.password
}

module "lb" {
  source          = "./modules/lb"
  rg_name         = module.networking.rg_name
  project_name    = var.project_name
  vnet_id         = module.networking.virtualnetwork_id
  rg_location     = module.networking.rg_location
  web1_private_ip = module.networking.web1_private_ip
  web2_private_ip = module.networking.web2_private_ip
}

