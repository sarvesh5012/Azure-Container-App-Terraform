
data "azurerm_client_config" "current" {}


# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aca_logs" {
  name                = "prod-aca-logs"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

}



resource "azurerm_key_vault" "aca_kv" {
  name                     = "prod-acakv-test-3"
  location                 = azurerm_resource_group.resource_group.location
  resource_group_name      = azurerm_resource_group.resource_group.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
      "Import",
      "Delete",
      "Update"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]
    
  }
  
}

resource "azurerm_key_vault_access_policy" "aca_kv_policy" {
  key_vault_id = azurerm_key_vault.aca_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_container_app.aca_app.identity[0].principal_id

  key_permissions = [
      "Create",
      "Get",
      "List",
      "Import",
      "Delete",
      "Update"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]

  depends_on = [azurerm_container_app.aca_app] # Ensure the Container App is created first
}



resource "azurerm_role_assignment" "key_vault_secret_user" {
  scope                = azurerm_key_vault.aca_kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app.aca_app.identity[0].principal_id
  depends_on           = [azurerm_container_app.aca_app]
}


resource "azurerm_key_vault_secret" "db_password" {
  name         = "DBPassword-test"
  value        = "SuperSecurePassword123!"
  key_vault_id = azurerm_key_vault.aca_kv.id

}


resource "azurerm_container_app_environment" "app_environment" {
  name                       = "prod-aca-env"
  location                   = azurerm_resource_group.resource_group.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca_logs.id
  infrastructure_subnet_id   = "/subscriptions/fd5cfbc8-9b6d-4996-9879-f5c2fc929e60/resourceGroups/virtue_RG_prod/providers/Microsoft.Network/virtualNetworks/virtue_VNet_prod/subnets/app-default"
  internal_load_balancer_enabled = false
  zone_redundancy_enabled = true

}

# Azure Container App with Environment Variables and Secrets
resource "azurerm_container_app" "aca_app" {
  name = "prod-multi-container-app"
  # location            = azurerm_resource_group.resource_group.location
  resource_group_name          = azurerm_resource_group.resource_group.name
  container_app_environment_id = azurerm_container_app_environment.app_environment.id
  revision_mode                = "Multiple"

  # Ingress Configuration with Host-based Routing
  ingress {
    external_enabled           = true
    target_port                = 3000
    transport                  = "http"
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      revision_suffix = "prod"
      percentage      = 100

    }

  }

  identity {
    type = "SystemAssigned"
  }

  secret {
  name                = "dbpassword"
  key_vault_secret_id = azurerm_key_vault_secret.db_password.id
  identity            = "System"
  }

  # Template Configuration with Multiple Containers
  template {
    revision_suffix = "prod"

    container {
      name   = "nginx-container"
      image  = "mayankgandhe/k-debugger"
      cpu    = "0.5"
      memory = "1.0Gi"
      

      env {
        name  = "ENVIRONMENT"
        value = "production"
      }

      liveness_probe {
        transport               = "HTTP"
        failure_count_threshold = 3
        port                    = 3000
        path                    = "/"

      }

      readiness_probe {
        transport               = "HTTP"
        failure_count_threshold = 3
        port                    = 3000
        path                    = "/"

      }


    }

    

    max_replicas = 6
    min_replicas = 2



  }


  tags = {
    environment = "production"
  }

}

resource "azurerm_dns_zone" "example" {
  name                = "virtues.agency"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_dns_txt_record" "domain-verification" {
  name                = "nginx.virtues.agency"
  zone_name           = azurerm_dns_zone.example.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300

  record {
    value = azurerm_container_app_environment.app_environment.custom_domain_verification_id
  }

}























