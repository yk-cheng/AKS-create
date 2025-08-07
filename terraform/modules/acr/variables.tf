# ACR Basic Configuration
variable "registry_name" {
  description = "Name of the Container Registry"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.registry_name))
    error_message = "Registry name must be 5-50 characters long and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "sku" {
  description = "SKU tier for the Container Registry"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for the Container Registry"
  type        = bool
  default     = false
}

# Network Configuration
variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "network_rule_set" {
  description = "Network rule set for IP and VNet restrictions"
  type = object({
    default_action = string
    ip_rule = optional(list(object({
      action   = string
      ip_range = string
    })))
    virtual_network = optional(list(object({
      action    = string
      subnet_id = string
    })))
  })
  default = null
}

# Private Endpoint Configuration
variable "enable_private_endpoint" {
  description = "Enable private endpoint for ACR"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = ""
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for private endpoint"
  type        = list(string)
  default     = []
}

variable "private_dns_zone_group_name" {
  description = "Name of the private DNS zone group"
  type        = string
  default     = "acr-dns-zone-group"
}

# Security and Policies
variable "retention_policy_enabled" {
  description = "Enable retention policy for untagged manifests (Premium SKU only)"
  type        = bool
  default     = false
}

variable "retention_policy_days" {
  description = "Retention policy for untagged manifests in days (Premium SKU only)"
  type        = number
  default     = 7
  validation {
    condition     = var.retention_policy_days >= 1 && var.retention_policy_days <= 365
    error_message = "Retention policy must be between 1 and 365 days."
  }
}

variable "trust_policy_enabled" {
  description = "Enable trust policy for signed images"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Enable zone redundancy for higher availability"
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "Enable export policy for data sovereignty"
  type        = bool
  default     = true
}

# Monitoring and Diagnostics
variable "enable_diagnostics" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = ""
}

# Access Control
variable "scope_maps" {
  description = "List of scope maps for repository permissions"
  type = list(object({
    name    = string
    actions = list(string)
  }))
  default = []
}

variable "tokens" {
  description = "List of tokens for authentication"
  type = list(object({
    name    = string
    enabled = bool
  }))
  default = []
}

# Resource Tagging
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}