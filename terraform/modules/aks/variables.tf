# AKS Cluster Variables
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

variable "kubernetes_version" {
  description = "Version of Kubernetes to use"
  type        = string
  default     = "1.33.2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# System Node Pool Variables
variable "system_node_count" {
  description = "Number of nodes in the system node pool"
  type        = number
  default     = 3
}

variable "system_node_vm_size" {
  description = "VM size for system nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "system_node_min_count" {
  description = "Minimum number of system nodes"
  type        = number
  default     = 3
}

variable "system_node_max_count" {
  description = "Maximum number of system nodes"
  type        = number
  default     = 6
}

# User Node Pool Variables
variable "user_node_count" {
  description = "Number of nodes in the user node pool"
  type        = number
  default     = 3
}

variable "user_node_vm_size" {
  description = "VM size for user nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "user_node_min_count" {
  description = "Minimum number of user nodes"
  type        = number
  default     = 3
}

variable "user_node_max_count" {
  description = "Maximum number of user nodes"
  type        = number
  default     = 20
}

variable "availability_zones" {
  description = "Availability zones for node pools"
  type        = list(string)
  default     = ["1", "2"]
}

# Network Variables
variable "subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
}

variable "vnet_id" {
  description = "Virtual Network ID"
  type        = string
}

variable "dns_service_ip" {
  description = "IP address for DNS service within service CIDR"
  type        = string
  default     = "10.2.0.10"
}

variable "service_cidr" {
  description = "Service CIDR for Kubernetes services"
  type        = string
  default     = "10.2.0.0/24"
}

variable "pod_cidr" {
  description = "Pod CIDR for Kubernetes pods (only used with kubenet)"
  type        = string
  default     = ""
}

variable "network_plugin" {
  description = "Network plugin to use (azure or kubenet)"
  type        = string
  default     = "azure"
  
  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  description = "Network policy to use (azure, calico, or none)"
  type        = string
  default     = "calico"
  
  validation {
    condition     = contains(["azure", "calico", ""], var.network_policy)
    error_message = "Network policy must be 'azure', 'calico', or empty string for none."
  }
}

# ACR Integration Variables
variable "acr_id" {
  description = "Azure Container Registry ID"
  type        = string
  default     = ""
}

# Service Principal variables removed - using SystemAssigned Identity instead

# Application Gateway Variables
variable "enable_application_gateway" {
  description = "Enable Application Gateway Ingress Controller"
  type        = bool
  default     = true
}

variable "application_gateway_id" {
  description = "Application Gateway ID for AGIC"
  type        = string
  default     = ""
}

# Monitoring Variables
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

# Azure AD Variables
variable "enable_azure_ad" {
  description = "Enable Azure AD (Entra) integration"
  type        = bool
  default     = false
}

variable "admin_group_object_ids" {
  description = "Azure AD admin group object IDs"
  type        = list(string)
  default     = []
}

variable "enable_azure_rbac" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}