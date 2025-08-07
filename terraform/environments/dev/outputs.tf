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