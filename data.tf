data "azurerm_resource_group" "rg_name" {
  name = azurerm_resource_group.resource_group.name
}

# data "azurerm_subnet" "selected_subnet" {
#   name                 = "subnet-app"
#   virtual_network_name = "${local.namespace}_VNet_${local.environment}"
#   resource_group_name  = azurerm_resource_group.resource_group.name
# }
