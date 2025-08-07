# Application Gateway Outputs
output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.agw.id
}

output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.agw.name
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.agw.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the Application Gateway public IP"
  value       = azurerm_public_ip.agw.fqdn
}

output "frontend_ip_configuration" {
  description = "Frontend IP configuration details"
  value = {
    name                 = azurerm_application_gateway.agw.frontend_ip_configuration[0].name
    public_ip_address_id = azurerm_application_gateway.agw.frontend_ip_configuration[0].public_ip_address_id
  }
}

output "identity_principal_id" {
  description = "Principal ID of the Application Gateway managed identity"
  value       = azurerm_application_gateway.agw.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "Tenant ID of the Application Gateway managed identity"
  value       = azurerm_application_gateway.agw.identity[0].tenant_id
}

# Diagnostic settings output
output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting (if enabled)"
  value       = var.enable_diagnostics ? azurerm_monitor_diagnostic_setting.agw[0].id : null
}