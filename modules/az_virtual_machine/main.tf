locals {
  data_disks = { for d in coalesce(var.vm_config.data_disks, []) : d.name => d }
  public_ip  = var.vm_config.public_ip ? { "public" = true } : {}
}

resource "azurerm_public_ip" "public_ip" {
  for_each = local.public_ip

  name                = "${var.vm_config.name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.vm_config.public_ip == true ? "Static" : "Dynamic"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "nt_interface" {
  name                = "${var.vm_config.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.public_ip["public"].id, null)
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_config.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_config.size
  admin_username      = var.vm_config.admin_username
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.nt_interface.id,
  ]

  admin_ssh_key {
    username   = var.vm_config.admin_username
    public_key = file(var.vm_config.admin_ssh_key_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_config.os_image.publisher
    offer     = var.vm_config.os_image.offer
    sku       = var.vm_config.os_image.sku
    version   = var.vm_config.os_image.version
  }
  custom_data = var.vm_config.custom_data

  dynamic "plan" {
    for_each = var.vm_config.plan != null ? [1] : []
    content {
      name      = var.vm_config.plan.name
      product   = var.vm_config.plan.product
      publisher = var.vm_config.plan.publisher
    }
  }
}


resource "azurerm_managed_disk" "mg_disk" {
  for_each = local.data_disks

  name                 = each.value.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  disk_size_gb         = each.value.disk_size_gb
  create_option        = "Empty"
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_disk_attach" {
  for_each = local.data_disks

  managed_disk_id    = azurerm_managed_disk.mg_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = each.value.lun
  caching            = "ReadWrite"
}
