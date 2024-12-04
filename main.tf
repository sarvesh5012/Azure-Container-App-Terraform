provider "azurerm" {
  features {}

  subscription_id = "fd5cfbc8-9b6d-4996-9879-f5c2fc929e60"

}

resource "azurerm_resource_group" "resource_group" {
  name     = "${local.namespace}_RG_${local.environment}"
  location = local.location
  tags     = local.common_tags
}


module "avm-res-network-virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  address_space       = [local.vnet_cidr_block]
  location            = local.location
  name                = "${local.namespace}_VNet_${local.environment}"
  resource_group_name = data.azurerm_resource_group.rg_name.name
  subnets = {
    
    "subnet1" = {
      name             = "subnet1"
      address_prefixes = ["10.0.0.0/24"]
    }
    "subnet2" = {
      name             = "subnet2"
      address_prefixes = ["10.0.1.0/24"]

    }

  }

}



