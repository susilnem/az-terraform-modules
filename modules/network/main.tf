check "nsg_and_route_table_keys_match_subnets" {
  assert {
    condition     = alltrue([for key in keys(var.nsg_configs) : contains(keys(var.subnet_configs), key)])
    error_message = "Every key in nsg_configs must match a key in subnet_configs. Found nsg_configs keys not present in subnet_configs: ${join(", ", setsubtract(keys(var.nsg_configs), keys(var.subnet_configs)))}"
  }

  assert {
    condition     = alltrue([for key in keys(var.route_table_configs) : contains(keys(var.subnet_configs), key)])
    error_message = "Every key in route_table_configs must match a key in subnet_configs. Found route_table_configs keys not present in subnet_configs: ${join(", ", setsubtract(keys(var.route_table_configs), keys(var.subnet_configs)))}"
  }
}

locals {
  nsg_configs_with_subnet         = { for key, value in var.nsg_configs : key => value if contains(keys(var.subnet_configs), key) }
  route_table_configs_with_subnet = { for key, value in var.route_table_configs : key => value if contains(keys(var.subnet_configs), key) }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_config.name
  address_space       = var.vnet_config.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_configs

  name                              = each.key
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = each.value.address_prefixes
  service_endpoints                 = lookup(each.value, "service_endpoints", null)
  private_endpoint_network_policies = each.value.private_endpoint_network_policies

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", null) != null ? each.value.delegations : []

    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each = local.nsg_configs_with_subnet

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = local.nsg_configs_with_subnet

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_route_table" "route_table" {
  for_each = local.route_table_configs_with_subnet

  name                = "rt-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "route" {
    for_each = lookup(each.value, "routes", [])
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
}

resource "azurerm_subnet_route_table_association" "route_table_association" {
  for_each = local.route_table_configs_with_subnet

  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.route_table[each.key].id
}
