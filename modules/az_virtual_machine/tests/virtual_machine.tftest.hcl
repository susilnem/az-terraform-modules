mock_provider "azurerm" {}

# azurerm validates the *shape* of ID-typed arguments at plan time regardless
# of provider mocking, so the public IP needs a realistically-shaped mock ID.
override_resource {
  target = azurerm_public_ip.public_ip
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/vm-test-public-ip"
  }
}

override_resource {
  target = azurerm_network_interface.nt_interface
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/vm-test-nic"
  }
}

variables {
  resource_group_name = "rg-test"
  location            = "eastus"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/public"

  vm_config = {
    name                     = "vm-test"
    size                     = "Standard_B1s"
    admin_username           = "azureadmin"
    admin_ssh_key_public_key = "tests/fixtures/dummy_key.pub"
    public_ip                = true
    os_image = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }
  }
}

run "valid_config_plans_successfully" {
  command = plan
}

run "rejects_invalid_size" {
  command = plan
  variables {
    vm_config = {
      name                     = "vm-test"
      size                     = "B1s"
      admin_username           = "azureadmin"
      admin_ssh_key_public_key = "tests/fixtures/dummy_key.pub"
      public_ip                = true
      os_image = {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
      }
    }
  }
  expect_failures = [var.vm_config]
}

run "rejects_disallowed_admin_username" {
  command = plan
  variables {
    vm_config = {
      name                     = "vm-test"
      size                     = "Standard_B1s"
      admin_username           = "administrator"
      admin_ssh_key_public_key = "tests/fixtures/dummy_key.pub"
      public_ip                = true
      os_image = {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
      }
    }
  }
  expect_failures = [var.vm_config]
}

run "rejects_duplicate_data_disk_luns" {
  command = plan
  variables {
    vm_config = {
      name                     = "vm-test"
      size                     = "Standard_B1s"
      admin_username           = "azureadmin"
      admin_ssh_key_public_key = "tests/fixtures/dummy_key.pub"
      public_ip                = true
      os_image = {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
      }
      data_disks = [
        {
          name                 = "disk-a"
          disk_size_gb         = 32
          storage_account_type = "Standard_LRS"
          lun                  = 0
        },
        {
          name                 = "disk-b"
          disk_size_gb         = 32
          storage_account_type = "Standard_LRS"
          lun                  = 0
        }
      ]
    }
  }
  expect_failures = [var.vm_config]
}
