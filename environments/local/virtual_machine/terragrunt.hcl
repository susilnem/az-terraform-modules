# This file represent the root module of the terragrunt configuration.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# NOTE: Loads the common variables from a certain folder/file
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("commonenv/common.hcl"))
}

# NOTE: Determines the modules and the environment variables
terraform {
  source = "../../../modules/az_virtual_machine/"
}

dependency "network" {
  config_path = find_in_parent_folders("network")

  mock_outputs = {
    subnets = {
      public  = "subnet-id-public"
    }
  }
}

inputs = merge(
    local.common_vars.locals.common_vars,
    {
      subnet_id = dependency.network.outputs.subnets["public"]
      vm_config = {
          name                     = "public-vm"
          subnet_key               = "public"
          size                     = "Standard_B1s"
          admin_username           = "adminuser"
          admin_ssh_key_public_key = "~/.ssh/id_rsa.pub"
          public_ip                = true
          os_image = {
            publisher = "Canonical"
            offer     = "UbuntuServer"
            sku       = "18.04-LTS"
            version   = "latest"
          }
      }
    }
)

