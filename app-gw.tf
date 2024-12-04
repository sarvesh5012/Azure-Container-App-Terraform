# # Public IP for Application Gateway
# resource "azurerm_public_ip" "appgw_public_ip" {
#   name                = "appgw-public-ip"
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# # Subnet for Application Gateway
# resource "azurerm_virtual_network" "vnet" {
#   name                = "appgw-vnet"
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name
#   address_space       = ["192.0.0.0/16"]
# }

# resource "azurerm_subnet" "appgw_subnet" {
#   name                 = "appgw-subnet"
#   resource_group_name  = azurerm_resource_group.resource_group.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["192.0.1.0/24"]
# }


# #################LB
# resource "azurerm_application_gateway" "app_gateway" {
#   name                = "prod-app-gateway"
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location
#   sku {
#     name     = "WAF_v2"
#     tier     = "WAF_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "appgw-ip-config"
#     subnet_id = azurerm_subnet.appgw_subnet.id
#   }

#   frontend_ip_configuration {
#     name                 = "appgw-frontend-ip"
#     public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
#   }

#   frontend_port {
#     name = "http-port"
#     port = 80
#   }

#   backend_address_pool {
#     name = "nginx-backend-pool"
#   }

#   backend_address_pool {
#     name = "apache-backend-pool"
#   }

#   http_listener {
#     name                           = "nginx-listener"
#     frontend_ip_configuration_name = "appgw-frontend-ip"
#     frontend_port_name             = "http-port"
#     host_name                      = "nginx.virtues.agency"
#     protocol                       = "Http"
#   }

#   http_listener {
#     name                           = "apache-listener"
#     frontend_ip_configuration_name = "appgw-frontend-ip"
#     frontend_port_name             = "http-port"
#     host_name                      = "apache.virtues.agency"
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                       = "nginx-rule"
#     rule_type                  = "Basic"
#     http_listener_name         = "nginx-listener"
#     backend_address_pool_name  = "nginx-backend-pool"
#     backend_http_settings_name = "http-settings"
#   }

#   request_routing_rule {
#     name                       = "apache-rule"
#     rule_type                  = "Basic"
#     http_listener_name         = "apache-listener"
#     backend_address_pool_name  = "apache-backend-pool"
#     backend_http_settings_name = "http-settings"
#   }

#   backend_http_settings {
#     name                  = "http-settings"
#     protocol              = "Http"
#     port                  = 80
#     request_timeout       = 20
#     cookie_based_affinity = "Disabled"
#   }
# }


