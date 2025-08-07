# Azure Container Registry Configuration

resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Public network access configuration
  public_network_access_enabled = var.public_network_access_enabled

  # Network rule set for IP restrictions
  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule != null ? network_rule_set.value.ip_rule : []
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }

      dynamic "virtual_network" {
        for_each = network_rule_set.value.virtual_network != null ? network_rule_set.value.virtual_network : []
        content {
          action    = virtual_network.value.action
          subnet_id = virtual_network.value.subnet_id
        }
      }
    }
  }

  # Retention policy for untagged manifests (Premium SKU only)
  dynamic "retention_policy" {
    for_each = var.sku == "Premium" && var.retention_policy_enabled ? [1] : []
    content {
      days    = var.retention_policy_days
      enabled = true
    }
  }

  # Trust policy for signed images (Premium SKU only)
  dynamic "trust_policy" {
    for_each = var.sku == "Premium" && var.trust_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Zone redundancy for higher availability
  zone_redundancy_enabled = var.zone_redundancy_enabled

  # Export policy for data sovereignty
  export_policy_enabled = var.export_policy_enabled

  tags = var.tags
}

# Diagnostic settings for ACR
resource "azurerm_monitor_diagnostic_setting" "acr" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.registry_name}-diagnostics"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = [
      {
        category = "ContainerRegistryRepositoryEvents"
        enabled  = true
      },
      {
        category = "ContainerRegistryLoginEvents" 
        enabled  = true
      }
    ]
    content {
      category = enabled_log.value.category
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Private endpoint for ACR (optional)
resource "azurerm_private_endpoint" "acr" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.registry_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.registry_name}-psc"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone_group_name
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Scope map for repository permissions (optional)
resource "azurerm_container_registry_scope_map" "main" {
  count                   = length(var.scope_maps)
  name                    = var.scope_maps[count.index].name
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = var.resource_group_name
  actions                 = var.scope_maps[count.index].actions
}

# Token for authentication (optional)
resource "azurerm_container_registry_token" "main" {
  count                   = length(var.tokens)
  name                    = var.tokens[count.index].name
  container_registry_name = azurerm_container_registry.acr.name
  resource_group_name     = var.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.main[count.index].id
  enabled                 = var.tokens[count.index].enabled
}