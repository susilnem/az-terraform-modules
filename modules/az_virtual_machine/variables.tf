variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
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
    subnet_key               = string
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
}
