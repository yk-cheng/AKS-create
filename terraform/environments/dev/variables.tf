# Variables for Dev Environment - Only Environment Specific Variables

# Basic Configuration
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# System Node Pool Variables (Environment specific sizing)
variable "system_node_count" {
  description = "Number of nodes in the system node pool"
  type        = number
}

variable "system_node_vm_size" {
  description = "VM size for system nodes"
  type        = string
}

variable "system_node_min_count" {
  description = "Minimum number of system nodes"
  type        = number
}

variable "system_node_max_count" {
  description = "Maximum number of system nodes"
  type        = number
}

# User Node Pool Variables (Environment specific sizing)
variable "user_node_count" {
  description = "Number of nodes in the user node pool"
  type        = number
}

variable "user_node_vm_size" {
  description = "VM size for user nodes"
  type        = string
}

variable "user_node_min_count" {
  description = "Minimum number of user nodes"
  type        = number
}

variable "user_node_max_count" {
  description = "Maximum number of user nodes"
  type        = number
}

# Network Variables (Environment specific networking)
variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = ""
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "subnet_name" {
  description = "Subnet name for AKS nodes"
  type        = string
  default     = ""
}

variable "subnet_address_prefixes" {
  description = "Subnet address prefixes for AKS nodes"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "dns_service_ip" {
  description = "IP address for DNS service within service CIDR"
  type        = string
}

variable "service_cidr" {
  description = "Service CIDR for Kubernetes services"
  type        = string
}

# Optional overrides (only if needed to override module defaults)
variable "kubernetes_version" {
  description = "Version of Kubernetes to use (optional override)"
  type        = string
  default     = ""
}

variable "network_plugin" {
  description = "Network plugin to use (optional override)"
  type        = string
  default     = ""
}

variable "network_policy" {
  description = "Network policy to use (optional override)"
  type        = string
  default     = ""
}

variable "pod_cidr" {
  description = "Pod CIDR for Kubernetes pods (optional)"
  type        = string
  default     = ""
}

# ACR Configuration
variable "enable_acr" {
  description = "Enable Azure Container Registry"
  type        = bool
  default     = false
}

variable "acr_sku" {
  description = "SKU tier for the Container Registry"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for the Container Registry"
  type        = bool
  default     = false
}

variable "acr_public_network_access_enabled" {
  description = "Enable public network access for ACR"
  type        = bool
  default     = true
}

variable "enable_application_gateway" {
  description = "Enable Application Gateway Ingress Controller"
  type        = bool
  default     = false
}

variable "application_gateway_id" {
  description = "Application Gateway ID for AGIC"
  type        = string
  default     = ""
}

variable "enable_log_analytics" {
  description = "Enable Log Analytics integration"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
  default     = ""
}

variable "admin_group_object_ids" {
  description = "Azure AD admin group object IDs"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}