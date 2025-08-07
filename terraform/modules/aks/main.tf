# AKS Cluster Configuration
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_vm_size
    type                = "VirtualMachineScaleSets"
    zones               = var.availability_zones
    enable_auto_scaling = true
    min_count           = var.system_node_min_count
    max_count           = var.system_node_max_count
    max_pods            = 30
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"

    vnet_subnet_id = var.subnet_id

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Network Configuration
  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy != "" ? var.network_policy : null
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    pod_cidr          = var.network_plugin == "kubenet" ? var.pod_cidr : null
    load_balancer_sku = "standard"
  }

  # Identity Configuration
  identity {
    type = "SystemAssigned"
  }

  # Azure Container Registry Integration handled via role assignment below

  # Add-ons Configuration
  azure_policy_enabled             = true
  http_application_routing_enabled = false

  dynamic "oms_agent" {
    for_each = var.enable_log_analytics ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.enable_application_gateway ? [1] : []
    content {
      gateway_id = var.application_gateway_id
    }
  }

  # Auto Scaler Profile
  auto_scaler_profile {
    balance_similar_node_groups      = false
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
    empty_bulk_delete_max            = 10
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }

  # Security Configuration
  role_based_access_control_enabled = true

  # Azure AD (Entra) Integration - Conditional configuration  
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_azure_ad ? [1] : []
    content {
      managed                = true
      admin_group_object_ids = var.admin_group_object_ids
      azure_rbac_enabled     = var.enable_azure_rbac
    }
  }

  tags = var.tags
}

# User Node Pool for Applications
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_vm_size
  node_count            = var.user_node_count
  zones                 = var.availability_zones
  enable_auto_scaling   = true
  min_count             = var.user_node_min_count
  max_count             = var.user_node_max_count
  max_pods              = 30
  os_disk_size_gb       = 128
  os_disk_type          = "Managed"

  vnet_subnet_id = var.subnet_id

  upgrade_settings {
    max_surge = "33%"
  }

  node_labels = {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "workload"      = "applications"
  }

  node_taints = []

  tags = var.tags
}

# ACR Integration Role Assignment
resource "azurerm_role_assignment" "acr_pull" {
  count                            = var.acr_id != "" && var.acr_id != null ? 1 : 0
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Network Contributor Role for CNI
resource "azurerm_role_assignment" "network_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name             = "Network Contributor"
  scope                            = var.vnet_id
  skip_service_principal_aad_check = true
}