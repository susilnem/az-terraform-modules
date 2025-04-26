variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_config" {
  description = "Virtual network configuration"
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "subnet_configs" {
  description = "Map of subnet configurations"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string))
    delegations = optional(list(object({
      name    = string
      actions = list(string)
    })))
  }))
}

variable "nsg_configs" {
  description = "Map of Network Security Group configurations per subnet"
  type = map(object({
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}

variable "route_table_configs" {
  description = "Map of Route Table configurations per subnet"
  type = map(object({
    routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })))
  }))
}
