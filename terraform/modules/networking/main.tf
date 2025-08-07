# Virtual Network for AKS
resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Subnet for AKS Nodes
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.subnet_address_prefixes

  # Disable private endpoint network policies
  private_endpoint_network_policies = "Disabled"
}

# Network Security Group - Default Allow All (for development)
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow All Inbound Traffic (Development Only)
  security_rule {
    name                       = "AllowAll"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Production Security Rules (Currently Commented Out)
  # Uncomment and modify for production deployment
  
  # security_rule {
  #   name                       = "SSH"
  #   priority                   = 1001
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "22"
  #   source_address_prefix      = "10.0.0.0/8"  # Limit to internal networks
  #   destination_address_prefix = "*"
  # }

  # security_rule {
  #   name                       = "HTTP"
  #   priority                   = 1002
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "80"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # security_rule {
  #   name                       = "HTTPS"
  #   priority                   = 1003
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "443"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # security_rule {
  #   name                       = "Kubernetes-API"
  #   priority                   = 1004
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "443"
  #   source_address_prefix      = "10.0.0.0/8"  # Limit to internal networks
  #   destination_address_prefix = "*"
  # }

  # security_rule {
  #   name                       = "DenyAll"
  #   priority                   = 4000
  #   direction                  = "Inbound"
  #   access                     = "Deny"
  #   protocol                   = "*"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  tags = var.tags
}

# Associate NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

# Application Gateway Subnet (Optional)
resource "azurerm_subnet" "agw_subnet" {
  count                = var.enable_application_gateway_subnet ? 1 : 0
  name                 = var.agw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.agw_subnet_address_prefixes

  # Application Gateway requires this to be disabled
  private_endpoint_network_policies = "Disabled"
}

# Network Security Group for Application Gateway - Default Allow All (Development)
resource "azurerm_network_security_group" "agw_nsg" {
  count               = var.enable_application_gateway_subnet ? 1 : 0
  name                = "${var.agw_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow All Inbound Traffic (Development Only)
  security_rule {
    name                       = "AllowAll"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG to Application Gateway Subnet
resource "azurerm_subnet_network_security_group_association" "agw_subnet_nsg" {
  count                     = var.enable_application_gateway_subnet ? 1 : 0
  subnet_id                 = azurerm_subnet.agw_subnet[0].id
  network_security_group_id = azurerm_network_security_group.agw_nsg[0].id
}