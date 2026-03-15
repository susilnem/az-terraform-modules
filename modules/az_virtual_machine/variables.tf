variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to place the VM in"
  type        = string
}

variable "vm_config" {
  description = "Virtual machine configuration"
  type = object({
    name                     = string
    size                     = string
    admin_username           = string
    admin_ssh_key_public_key = string
    public_ip                = bool
    custom_data              = optional(string)

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
    condition = (
      var.vm_config.data_disks == null
      || length(distinct([for d in var.vm_config.data_disks : d.name])) == length(var.vm_config.data_disks)
    )
    error_message = "vm_config.data_disks disk names must be unique."
  }

  validation {
    condition = (
      var.vm_config.data_disks == null
      || length(distinct([for d in var.vm_config.data_disks : d.lun])) == length(var.vm_config.data_disks)
    )
    error_message = "vm_config.data_disks LUN values must be unique."
  }
}
