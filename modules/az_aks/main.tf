resource "azurerm_kubernetes_cluster" "aks" {
  name                       = var.aks_config.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  dns_prefix                 = var.aks_config.private_cluster_enabled ? null : var.aks_config.dns_prefix
  dns_prefix_private_cluster = var.aks_config.private_cluster_enabled ? var.aks_config.dns_prefix : null
  kubernetes_version         = var.aks_config.kubernetes_version
  tags                       = var.tags

  private_cluster_enabled           = var.aks_config.private_cluster_enabled
  local_account_disabled            = var.aks_config.local_account_disabled
  automatic_upgrade_channel         = var.aks_config.automatic_upgrade_channel
  oidc_issuer_enabled               = var.aks_config.oidc_issuer_enabled
  workload_identity_enabled         = var.aks_config.workload_identity_enabled
  role_based_access_control_enabled = true

  default_node_pool {
    name                 = var.aks_config.default_node_pool.name
    vm_size              = var.aks_config.default_node_pool.vm_size
    vnet_subnet_id       = var.subnet_id
    os_disk_size_gb      = var.aks_config.default_node_pool.os_disk_size_gb
    os_disk_type         = var.aks_config.default_node_pool.os_disk_type
    max_pods             = var.aks_config.default_node_pool.max_pods
    zones                = var.aks_config.default_node_pool.zones
    auto_scaling_enabled = var.aks_config.default_node_pool.auto_scaling_enabled
    node_count           = var.aks_config.default_node_pool.auto_scaling_enabled ? null : var.aks_config.default_node_pool.node_count
    min_count            = var.aks_config.default_node_pool.auto_scaling_enabled ? var.aks_config.default_node_pool.min_count : null
    max_count            = var.aks_config.default_node_pool.auto_scaling_enabled ? var.aks_config.default_node_pool.max_count : null
  }

  dynamic "identity" {
    for_each = [var.aks_config.identity_type]
    content {
      type = identity.value
    }
  }

  dynamic "network_profile" {
    for_each = var.aks_config.network_profile != null ? [var.aks_config.network_profile] : []
    content {
      network_plugin = network_profile.value.network_plugin
      network_policy = lookup(network_profile.value, "network_policy", null)
      service_cidr   = lookup(network_profile.value, "service_cidr", null)
      dns_service_ip = lookup(network_profile.value, "dns_service_ip", null)
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.aks_config.azure_active_directory_rbac != null ? [var.aks_config.azure_active_directory_rbac] : []
    content {
      tenant_id              = lookup(azure_active_directory_role_based_access_control.value, "tenant_id", null)
      admin_group_object_ids = lookup(azure_active_directory_role_based_access_control.value, "admin_group_object_ids", null)
      azure_rbac_enabled     = lookup(azure_active_directory_role_based_access_control.value, "azure_rbac_enabled", false)
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.aks_config.authorized_ip_ranges != null ? [var.aks_config.authorized_ip_ranges] : []
    content {
      authorized_ip_ranges = api_server_access_profile.value
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.aks_config.microsoft_defender_log_analytics_workspace_id != null ? [var.aks_config.microsoft_defender_log_analytics_workspace_id] : []
    content {
      log_analytics_workspace_id = microsoft_defender.value
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  count = length(var.aks_config.additional_node_pools)

  name                  = var.aks_config.additional_node_pools[count.index].name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_config.additional_node_pools[count.index].vm_size
  vnet_subnet_id        = var.subnet_id
  os_disk_size_gb       = var.aks_config.additional_node_pools[count.index].os_disk_size_gb
  os_disk_type          = var.aks_config.additional_node_pools[count.index].os_disk_type
  max_pods              = var.aks_config.additional_node_pools[count.index].max_pods
  zones                 = var.aks_config.additional_node_pools[count.index].zones
  auto_scaling_enabled  = var.aks_config.additional_node_pools[count.index].auto_scaling_enabled
  node_count            = var.aks_config.additional_node_pools[count.index].auto_scaling_enabled ? null : var.aks_config.additional_node_pools[count.index].node_count
  min_count             = var.aks_config.additional_node_pools[count.index].auto_scaling_enabled ? var.aks_config.additional_node_pools[count.index].min_count : null
  max_count             = var.aks_config.additional_node_pools[count.index].auto_scaling_enabled ? var.aks_config.additional_node_pools[count.index].max_count : null
  tags                  = var.tags
}
