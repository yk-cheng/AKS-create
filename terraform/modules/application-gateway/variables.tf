# Application Gateway Basic Configuration
variable "application_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

# SKU Configuration
variable "sku_name" {
  description = "Name of the Application Gateway SKU"
  type        = string
  default     = "Standard_v2"
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "SKU name must be Standard_v2 or WAF_v2."
  }
}

variable "sku_tier" {
  description = "Tier of the Application Gateway SKU"
  type        = string
  default     = "Standard_v2"
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be Standard_v2 or WAF_v2."
  }
}

variable "capacity" {
  description = "Capacity (instance count) of the Application Gateway"
  type        = number
  default     = 2
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 125
    error_message = "Capacity must be between 1 and 125."
  }
}

# Availability and Scaling
variable "availability_zones" {
  description = "Availability zones for the Application Gateway"
  type        = list(string)
  default     = ["1", "2"]
}

variable "enable_autoscale" {
  description = "Enable autoscaling for the Application Gateway"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 2
  validation {
    condition     = var.min_capacity >= 1 && var.min_capacity <= 125
    error_message = "Min capacity must be between 1 and 125."
  }
}

variable "max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 10
  validation {
    condition     = var.max_capacity >= 2 && var.max_capacity <= 125
    error_message = "Max capacity must be between 2 and 125."
  }
}

# WAF Configuration
variable "enable_waf" {
  description = "Enable Web Application Firewall"
  type        = bool
  default     = false
}

variable "waf_mode" {
  description = "WAF mode (Detection or Prevention)"
  type        = string
  default     = "Detection"
  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be Detection or Prevention."
  }
}

variable "waf_rule_set_version" {
  description = "WAF rule set version"
  type        = string
  default     = "3.2"
}

variable "waf_file_upload_limit_mb" {
  description = "WAF file upload limit in MB"
  type        = number
  default     = 100
}

variable "waf_request_body_check" {
  description = "Enable WAF request body check"
  type        = bool
  default     = true
}

variable "waf_max_request_body_size_kb" {
  description = "WAF maximum request body size in KB"
  type        = number
  default     = 128
}

# SSL Configuration
variable "ssl_certificates" {
  description = "List of SSL certificates"
  type = list(object({
    name     = string
    data     = string
    password = string
  }))
  default = []
  sensitive = true
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

# Resource Tagging
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}