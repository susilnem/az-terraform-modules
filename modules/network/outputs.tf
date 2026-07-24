output "network_vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "network_subnets" {
  description = "Map of subnet key to subnet ID"
  value       = { for k, subnet in azurerm_subnet.subnet : k => subnet.id }
}

output "network_subnet_names" {
  description = "Map of subnet key to subnet name"
  value       = { for k, subnet in azurerm_subnet.subnet : k => subnet.name }
}

output "network_nsg_ids" {
  description = "The IDs and names of the network security groups"
  value = {
    for k, nsg in azurerm_network_security_group.nsg : k => {
      id   = nsg.id
      name = nsg.name
    }
  }
}

output "network_route_table_ids" {
  description = "The IDs and names of the route tables"
  value = {
    for k, route_table in azurerm_route_table.route_table : k => {
      id   = route_table.id
      name = route_table.name
    }
  }
}

output "network_nsg_associations" {
  description = "The IDs of the network security group associations"
  value = {
    for k, association in azurerm_subnet_network_security_group_association.nsg_association : k => {
      subnet_id                 = association.subnet_id
      network_security_group_id = association.network_security_group_id
    }
  }
}
