# Networking Module Variables

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the AKS subnet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Application Gateway Subnet Configuration
variable "enable_application_gateway_subnet" {
  description = "Enable Application Gateway subnet"
  type        = bool
  default     = false
}

variable "agw_subnet_name" {
  description = "Name of the Application Gateway subnet"
  type        = string
  default     = "subnet-agw"
}

variable "agw_subnet_address_prefixes" {
  description = "Address prefixes for the Application Gateway subnet"
  type        = list(string)
  default     = ["10.1.2.0/24"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}