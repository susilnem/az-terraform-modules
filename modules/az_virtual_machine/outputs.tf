output "vm_id" {
  description = "The ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_public_ip" {
  description = "The public IP address of the virtual machine."
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "vm_private_ip" {
  description = "The private IP address of the virtual machine."
  value = azurerm_linux_virtual_machine.vm.private_ip_address
}

output "vm_admin_username" {
  description = "The admin username of the virtual machine."
  value       = azurerm_linux_virtual_machine.vm.admin_username
}

output "vm_os_disk_id" {
  description = "The ID of the OS disk of the virtual machine."
  value       = azurerm_linux_virtual_machine.vm.os_disk[0]
}
output "vm_data_disks" {
  description = "The IDs of the data disks attached to the virtual machine."
  value = azurerm_managed_disk.mg_disk[*].id
}

output "vm_network_interface_id" {
  description = "The ID of the network interface attached to the virtual machine."
  value       = azurerm_network_interface.nt_interface.id
}

output "vm_network_interface_private_ip" {
  description = "The private IP address of the network interface attached to the virtual machine."
  value       = azurerm_network_interface.nt_interface.private_ip_address
}
