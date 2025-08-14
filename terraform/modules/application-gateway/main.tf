# Application Gateway Configuration for AGIC

# Public IP for Application Gateway
resource "azurerm_public_ip" "agw" {
  name                = "${var.application_gateway_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "agw" {
  name                = var.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.enable_autoscale ? null : var.capacity
  }

  zones = var.availability_zones

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "default-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "default-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-routing-rule"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "default-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-backend-http-settings"
  }

  # WAF Configuration (if enabled)
  dynamic "waf_configuration" {
    for_each = var.enable_waf ? [1] : []
    content {
      enabled                  = true
      firewall_mode           = var.waf_mode
      rule_set_type           = "OWASP"
      rule_set_version        = var.waf_rule_set_version
      file_upload_limit_mb    = var.waf_file_upload_limit_mb
      request_body_check      = var.waf_request_body_check
      max_request_body_size_kb = var.waf_max_request_body_size_kb
    }
  }

  # SSL Configuration (commented out for dev environment)
  # dynamic "ssl_certificate" {
  #   for_each = var.ssl_certificates
  #   content {
  #     name     = ssl_certificate.value.name
  #     data     = ssl_certificate.value.data
  #     password = ssl_certificate.value.password
  #   }
  # }

  # Autoscale configuration
  dynamic "autoscale_configuration" {
    for_each = var.enable_autoscale ? [1] : []
    content {
      min_capacity = var.min_capacity
      max_capacity = var.max_capacity
    }
  }

  # Identity for AGIC (commented out - AGIC will be managed by AKS addon)
  # identity {
  #   type = "UserAssigned"  # Application Gateway only supports UserAssigned
  #   identity_ids = [var.user_assigned_identity_id]
  # }

  tags = var.tags

  lifecycle {
    # Ignore changes to backend address pool and backend http settings
    # as these will be managed by AGIC
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      url_path_map,
      probe
    ]
  }
}

# Diagnostic settings for Application Gateway
resource "azurerm_monitor_diagnostic_setting" "agw" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.application_gateway_name}-diagnostics"
  target_resource_id         = azurerm_application_gateway.agw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = [
      {
        category = "ApplicationGatewayAccessLog"
        enabled  = true
      },
      {
        category = "ApplicationGatewayPerformanceLog"
        enabled  = true
      },
      {
        category = "ApplicationGatewayFirewallLog"
        enabled  = var.enable_waf
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