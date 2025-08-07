# Networking Module Outputs

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.aks_vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.aks_vnet.name
}

output "subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.id
}

output "subnet_name" {
  description = "Name of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.name
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.aks_nsg.id
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.aks_vnet.address_space
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.address_prefixes
}

# Application Gateway Subnet Outputs
output "agw_subnet_id" {
  description = "ID of the Application Gateway subnet (if created)"
  value       = var.enable_application_gateway_subnet ? azurerm_subnet.agw_subnet[0].id : null
}

output "agw_subnet_name" {
  description = "Name of the Application Gateway subnet (if created)"
  value       = var.enable_application_gateway_subnet ? azurerm_subnet.agw_subnet[0].name : null
}

output "agw_nsg_id" {
  description = "ID of the Application Gateway Network Security Group (if created)"
  value       = var.enable_application_gateway_subnet ? azurerm_network_security_group.agw_nsg[0].id : null
}