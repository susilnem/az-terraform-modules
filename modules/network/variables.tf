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

variable "vnet_config" {
  description = "Virtual network configuration"
  type = object({
    name          = string
    address_space = list(string)
  })

  validation {
    condition     = alltrue([for cidr in var.vnet_config.address_space : can(cidrhost(cidr, 0))])
    error_message = "vnet_config.address_space must contain only valid CIDR blocks."
  }
}

variable "subnet_configs" {
  description = "Map of subnet configurations"
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string))
    private_endpoint_network_policies = optional(string, "Enabled")
    delegations = optional(list(object({
      name    = string
      actions = list(string)
    })))
  }))

  validation {
    condition = alltrue([
      for subnet in var.subnet_configs :
      alltrue([for cidr in subnet.address_prefixes : can(cidrhost(cidr, 0))])
    ])
    error_message = "subnet_configs.*.address_prefixes must contain only valid CIDR blocks."
  }

  validation {
    condition = alltrue([
      for subnet in var.subnet_configs :
      contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], subnet.private_endpoint_network_policies)
    ])
    error_message = "subnet_configs.*.private_endpoint_network_policies must be one of \"Disabled\", \"Enabled\", \"NetworkSecurityGroupEnabled\", \"RouteTableEnabled\"."
  }
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
  default = {}

  validation {
    condition = alltrue(flatten([
      for nsg in var.nsg_configs : [
        for rule in nsg.security_rules : rule.priority >= 100 && rule.priority <= 4096
      ]
    ]))
    error_message = "nsg_configs.*.security_rules[*].priority must be between 100 and 4096."
  }

  validation {
    condition = alltrue(flatten([
      for nsg in var.nsg_configs : [
        for rule in nsg.security_rules : contains(["Inbound", "Outbound"], rule.direction)
      ]
    ]))
    error_message = "nsg_configs.*.security_rules[*].direction must be \"Inbound\" or \"Outbound\"."
  }

  validation {
    condition = alltrue(flatten([
      for nsg in var.nsg_configs : [
        for rule in nsg.security_rules : contains(["Allow", "Deny"], rule.access)
      ]
    ]))
    error_message = "nsg_configs.*.security_rules[*].access must be \"Allow\" or \"Deny\"."
  }

  validation {
    condition = alltrue(flatten([
      for nsg in var.nsg_configs : [
        for rule in nsg.security_rules : contains(["Tcp", "Udp", "Icmp", "*"], rule.protocol)
      ]
    ]))
    error_message = "nsg_configs.*.security_rules[*].protocol must be one of \"Tcp\", \"Udp\", \"Icmp\", \"*\"."
  }
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
  default = {}

  validation {
    condition = alltrue(flatten([
      for rt in var.route_table_configs : [
        for route in coalesce(rt.routes, []) : contains(
          ["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"],
          route.next_hop_type
        )
      ]
    ]))
    error_message = "route_table_configs.*.routes[*].next_hop_type must be one of \"VirtualNetworkGateway\", \"VnetLocal\", \"Internet\", \"VirtualAppliance\", \"None\"."
  }
}
