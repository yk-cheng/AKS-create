# ACR Resource Outputs
output "registry_id" {
  description = "ID of the Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "registry_name" {
  description = "Name of the Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "Login server URL for the Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "Admin username for the Container Registry"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "Admin password for the Container Registry"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# Network Configuration Outputs
output "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  value       = azurerm_container_registry.acr.public_network_access_enabled
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if created)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.acr[0].id : null
}

output "private_endpoint_fqdn" {
  description = "FQDN of the private endpoint (if created)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.acr[0].custom_dns_configs[0].fqdn : null
}

# Access Control Outputs
output "scope_map_ids" {
  description = "IDs of created scope maps"
  value       = azurerm_container_registry_scope_map.main[*].id
}

output "token_ids" {
  description = "IDs of created tokens"
  value       = azurerm_container_registry_token.main[*].id
}

# Diagnostic Settings Output
output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting (if enabled)"
  value       = var.enable_diagnostics ? azurerm_monitor_diagnostic_setting.acr[0].id : null
}