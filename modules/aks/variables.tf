variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.location))
    error_message = "location must be a valid Azure region name (lowercase letters and digits only, e.g. \"eastus\")."
  }
}

variable "tags" {
  description = "Tags to apply to all taggable resources"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "ID of the subnet to place the AKS default node pool (and any additional node pools) in"
  type        = string
}

variable "aks_config" {
  description = "AKS cluster configuration"
  type = object({
    name               = string
    dns_prefix         = string
    kubernetes_version = optional(string)

    default_node_pool = object({
      name                 = string
      node_count           = optional(number)
      vm_size              = string
      os_disk_size_gb      = optional(number)
      os_disk_type         = optional(string, "Managed")
      max_pods             = optional(number)
      zones                = optional(list(string))
      auto_scaling_enabled = optional(bool, false)
      min_count            = optional(number)
      max_count            = optional(number)
    })

    identity_type = optional(string, "SystemAssigned")

    network_profile = optional(object({
      network_plugin = string
      network_policy = optional(string)
      service_cidr   = optional(string)
      dns_service_ip = optional(string)
    }))

    additional_node_pools = optional(list(object({
      name                 = string
      vm_size              = string
      node_count           = optional(number)
      os_disk_size_gb      = optional(number)
      os_disk_type         = optional(string, "Managed")
      max_pods             = optional(number)
      zones                = optional(list(string))
      auto_scaling_enabled = optional(bool, false)
      min_count            = optional(number)
      max_count            = optional(number)
    })), [])

    private_cluster_enabled   = optional(bool, false)
    authorized_ip_ranges      = optional(list(string))
    local_account_disabled    = optional(bool, false)
    automatic_upgrade_channel = optional(string)
    oidc_issuer_enabled       = optional(bool, false)
    workload_identity_enabled = optional(bool, false)

    azure_active_directory_rbac = optional(object({
      tenant_id              = optional(string)
      admin_group_object_ids = optional(list(string))
      azure_rbac_enabled     = optional(bool, false)
    }))

    microsoft_defender_log_analytics_workspace_id = optional(string)
  })

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,54}$", var.aks_config.dns_prefix))
    error_message = "aks_config.dns_prefix must be 1-54 characters, containing only letters, numbers, and hyphens."
  }

  validation {
    condition     = var.aks_config.kubernetes_version == null || can(regex("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", var.aks_config.kubernetes_version))
    error_message = "aks_config.kubernetes_version must be in the form \"<major>.<minor>\" or \"<major>.<minor>.<patch>\"."
  }

  validation {
    condition     = can(regex("^Standard_", var.aks_config.default_node_pool.vm_size))
    error_message = "aks_config.default_node_pool.vm_size must be a valid Azure VM size (e.g. \"Standard_B2s\")."
  }

  validation {
    condition = try(
      var.aks_config.default_node_pool.auto_scaling_enabled
      ? (var.aks_config.default_node_pool.min_count != null && var.aks_config.default_node_pool.max_count != null && var.aks_config.default_node_pool.min_count > 0)
      : (var.aks_config.default_node_pool.node_count != null && var.aks_config.default_node_pool.node_count > 0),
      false
    )
    error_message = "aks_config.default_node_pool must set node_count > 0 when auto_scaling_enabled is false, or min_count/max_count (min_count > 0) when auto_scaling_enabled is true."
  }

  validation {
    condition = alltrue([
      for pool in var.aks_config.additional_node_pools :
      try(
        pool.auto_scaling_enabled
        ? (pool.min_count != null && pool.max_count != null && pool.min_count > 0)
        : (pool.node_count != null && pool.node_count > 0),
        false
      )
    ])
    error_message = "aks_config.additional_node_pools[*] must set node_count > 0 when auto_scaling_enabled is false, or min_count/max_count (min_count > 0) when auto_scaling_enabled is true."
  }

  validation {
    condition = alltrue([
      for pool in var.aks_config.additional_node_pools : can(regex("^Standard_", pool.vm_size))
    ])
    error_message = "aks_config.additional_node_pools[*].vm_size must be a valid Azure VM size (e.g. \"Standard_B2s\")."
  }

  validation {
    condition = alltrue([
      for pool in var.aks_config.additional_node_pools : pool.name != "default" && pool.name != var.aks_config.default_node_pool.name
    ])
    error_message = "aks_config.additional_node_pools[*].name must not collide with the default node pool's name."
  }

  validation {
    condition     = length(var.aks_config.additional_node_pools) == length(distinct([for pool in var.aks_config.additional_node_pools : pool.name]))
    error_message = "aks_config.additional_node_pools[*].name values must be unique."
  }

  validation {
    condition     = var.aks_config.automatic_upgrade_channel == null || try(contains(["patch", "rapid", "node-image", "stable", "none"], var.aks_config.automatic_upgrade_channel), false)
    error_message = "aks_config.automatic_upgrade_channel must be one of \"patch\", \"rapid\", \"node-image\", \"stable\", \"none\"."
  }
}
