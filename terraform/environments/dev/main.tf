# Development Environment AKS Configuration

terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Backend configuration - Comment out for local testing
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstatedev"
  #   container_name       = "tfstate"
  #   key                  = "aks-dev.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  vnet_name              = var.vnet_name != "" ? var.vnet_name : "vnet-${var.environment}"
  vnet_address_space     = var.vnet_address_space
  subnet_name            = var.subnet_name != "" ? var.subnet_name : "subnet-aks-${var.environment}"
  subnet_address_prefixes = var.subnet_address_prefixes
  
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags               = var.tags
}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# ACR Module (Optional for dev)
module "acr" {
  count  = var.enable_acr ? 1 : 0
  source = "../../modules/acr"

  registry_name       = "acr${var.environment}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  sku                = var.acr_sku
  admin_enabled      = var.acr_admin_enabled
  
  # Network configuration
  public_network_access_enabled = var.acr_public_network_access_enabled
  
  # Monitoring
  enable_diagnostics           = var.enable_log_analytics
  log_analytics_workspace_id   = var.log_analytics_workspace_id
  
  tags = var.tags
}

# AKS Module
module "aks" {
  source = "../../modules/aks"

  # Basic Configuration
  cluster_name        = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix
  # kubernetes_version uses module default (1.33.2)
  # kubernetes_version = var.kubernetes_version
  environment         = var.environment

  # System Node Pool
  system_node_count     = var.system_node_count
  system_node_vm_size   = var.system_node_vm_size
  system_node_min_count = var.system_node_min_count
  system_node_max_count = var.system_node_max_count

  # User Node Pool
  user_node_count     = var.user_node_count
  user_node_vm_size   = var.user_node_vm_size
  user_node_min_count = var.user_node_min_count
  user_node_max_count = var.user_node_max_count

  # Network Configuration
  subnet_id      = module.networking.subnet_id
  vnet_id        = module.networking.vnet_id
  dns_service_ip = var.dns_service_ip
  service_cidr   = var.service_cidr
  
  # Network plugin and policy use module defaults (azure + calico)
  # Uncomment below only if you need to override defaults
  # network_plugin = var.network_plugin != "" ? var.network_plugin : "azure"
  # network_policy = var.network_policy != "" ? var.network_policy : "calico"
  # pod_cidr       = var.pod_cidr

  # ACR Integration
  acr_id = var.enable_acr ? module.acr[0].registry_id : ""

  # Application Gateway
  enable_application_gateway = var.enable_application_gateway
  application_gateway_id     = var.application_gateway_id

  # Monitoring
  enable_log_analytics       = var.enable_log_analytics
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Azure AD
  admin_group_object_ids = var.admin_group_object_ids

  # Tags
  tags = var.tags
}