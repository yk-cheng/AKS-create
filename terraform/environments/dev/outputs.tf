# Outputs for Dev Environment

output "cluster_id" {
  description = "AKS Cluster ID"
  value       = module.aks.cluster_id
}

output "cluster_name" {
  description = "AKS Cluster Name"
  value       = module.aks.cluster_name
}

output "cluster_fqdn" {
  description = "AKS Cluster FQDN"
  value       = module.aks.cluster_fqdn
}

output "kube_config" {
  description = "Kubeconfig for kubectl access"
  value       = module.aks.kube_config
  sensitive   = true
}

output "cluster_identity" {
  description = "AKS Cluster Identity"
  value       = module.aks.cluster_identity
}

output "kubelet_identity" {
  description = "AKS Kubelet Identity"
  value       = module.aks.kubelet_identity
}

output "oidc_issuer_url" {
  description = "OIDC Issuer URL for Workload Identity"
  value       = module.aks.oidc_issuer_url
}

# ACR Outputs
output "acr_id" {
  description = "Azure Container Registry ID"
  value       = var.enable_acr ? module.acr[0].registry_id : null
}

output "acr_name" {
  description = "Azure Container Registry Name"
  value       = var.enable_acr ? module.acr[0].registry_name : null
}

output "acr_login_server" {
  description = "Azure Container Registry Login Server"
  value       = var.enable_acr ? module.acr[0].login_server : null
}

# Networking Outputs
output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.networking.vnet_id
}

output "subnet_id" {
  description = "AKS Subnet ID"
  value       = module.networking.subnet_id
}

output "agw_subnet_id" {
  description = "Application Gateway Subnet ID"
  value       = module.networking.agw_subnet_id
}

# Application Gateway Outputs
output "application_gateway_id" {
  description = "Application Gateway ID"
  value       = var.enable_application_gateway ? module.application_gateway[0].application_gateway_id : null
}

output "application_gateway_name" {
  description = "Application Gateway Name"
  value       = var.enable_application_gateway ? module.application_gateway[0].application_gateway_name : null
}

output "application_gateway_public_ip" {
  description = "Application Gateway Public IP"
  value       = var.enable_application_gateway ? module.application_gateway[0].public_ip_address : null
}

output "application_gateway_fqdn" {
  description = "Application Gateway FQDN"
  value       = var.enable_application_gateway ? module.application_gateway[0].public_ip_fqdn : null
}