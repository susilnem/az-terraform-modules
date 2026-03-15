output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = module.network.subnets
}

output "nsg_ids" {
  description = "The IDs of the network security groups"
  value       = module.network.nsg_ids
}

output "route_table_ids" {
  description = "The IDs of the route tables"
  value       = module.network.route_table_ids
}

output "nsg_associations" {
  description = "The IDs of the network security group association"
  value       = module.network.nsg_associations
}

output "virtual_machines" {
  description = "The details of the virtual machines"
  value = {
    for vm, vm_config in module.virtual_machines :
    vm => {
      id                           = vm_config.vm_id
      public_ip                    = vm_config.vm_public_ip
      private_ip                   = vm_config.vm_private_ip
      admin_username               = vm_config.vm_admin_username
      os_disk_id                   = vm_config.vm_os_disk_id
      data_disks                   = vm_config.vm_data_disks
      network_interface_id         = vm_config.vm_network_interface_id
      network_interface_private_ip = vm_config.vm_network_interface_private_ip
    }
  }
}
