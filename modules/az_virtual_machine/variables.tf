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
  description = "ID of the subnet to place the VM in"
  type        = string
}

variable "vm_config" {
  description = "Virtual machine configuration"
  type = object({
    name                       = string
    size                       = string
    admin_username             = string
    admin_ssh_key_public_key   = string
    public_ip                  = bool
    custom_data                = optional(string)
    encryption_at_host_enabled = optional(bool, false)
    patch_mode                 = optional(string, "AutomaticByPlatform")
    patch_assessment_mode      = optional(string, "AutomaticByPlatform")
    os_image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    plan = optional(object({
      name      = string
      product   = string
      publisher = string
    }))
    data_disks = optional(list(object({
      name                 = string
      disk_size_gb         = number
      storage_account_type = string
      lun                  = number
    })))
  })

  validation {
    condition     = can(regex("^Standard_", var.vm_config.size))
    error_message = "vm_config.size must be a valid Azure VM size (e.g. \"Standard_B1s\")."
  }

  validation {
    condition     = !contains(["admin", "administrator", "root", "guest", "user", "user1", "test", "test1", "test2", "test3"], lower(var.vm_config.admin_username))
    error_message = "vm_config.admin_username must not be an Azure-disallowed reserved username (e.g. \"admin\", \"administrator\", \"root\")."
  }

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.vm_config.patch_mode)
    error_message = "vm_config.patch_mode must be \"AutomaticByPlatform\" or \"ImageDefault\"."
  }

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.vm_config.patch_assessment_mode)
    error_message = "vm_config.patch_assessment_mode must be \"AutomaticByPlatform\" or \"ImageDefault\"."
  }

  validation {
    condition = (
      lookup(var.vm_config, "data_disks", null) == null ||
      try(length(var.vm_config.data_disks) == length(distinct([for d in var.vm_config.data_disks : d.lun])), false)
    )
    error_message = "vm_config.data_disks[*].lun values must be unique."
  }
}
