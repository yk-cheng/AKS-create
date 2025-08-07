# AKS Cluster Outputs
output "cluster_id" {
  description = "AKS Cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "AKS Cluster Name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "AKS Cluster FQDN"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "cluster_endpoint" {
  description = "AKS Cluster API Server Endpoint"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "AKS Cluster CA Certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

# Kubeconfig
output "kube_config" {
  description = "Complete kubeconfig"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

# Identity Information
output "cluster_identity" {
  description = "AKS Cluster Identity"
  value = {
    type         = azurerm_kubernetes_cluster.aks.identity[0].type
    principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
  }
}

output "kubelet_identity" {
  description = "AKS Kubelet Identity"
  value = {
    client_id                 = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
    object_id                 = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].user_assigned_identity_id
  }
}

# Node Pool Information
output "system_node_pool" {
  description = "System node pool information"
  value = {
    name       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
    vm_size    = azurerm_kubernetes_cluster.aks.default_node_pool[0].vm_size
    node_count = azurerm_kubernetes_cluster.aks.default_node_pool[0].node_count
    max_count  = azurerm_kubernetes_cluster.aks.default_node_pool[0].max_count
    min_count  = azurerm_kubernetes_cluster.aks.default_node_pool[0].min_count
  }
}

output "user_node_pool" {
  description = "User node pool information"
  value = {
    name       = azurerm_kubernetes_cluster_node_pool.user.name
    vm_size    = azurerm_kubernetes_cluster_node_pool.user.vm_size
    node_count = azurerm_kubernetes_cluster_node_pool.user.node_count
    max_count  = azurerm_kubernetes_cluster_node_pool.user.max_count
    min_count  = azurerm_kubernetes_cluster_node_pool.user.min_count
  }
}

# Network Information
output "network_profile" {
  description = "AKS Network Profile"
  value = {
    network_plugin = azurerm_kubernetes_cluster.aks.network_profile[0].network_plugin
    network_policy = azurerm_kubernetes_cluster.aks.network_profile[0].network_policy
    dns_service_ip = azurerm_kubernetes_cluster.aks.network_profile[0].dns_service_ip
    service_cidr   = azurerm_kubernetes_cluster.aks.network_profile[0].service_cidr
    pod_cidr       = azurerm_kubernetes_cluster.aks.network_profile[0].pod_cidr
  }
}

# OIDC Issuer URL (for Workload Identity)
output "oidc_issuer_url" {
  description = "OIDC Issuer URL for Workload Identity"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}