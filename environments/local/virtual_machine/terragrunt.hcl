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
  source = "../../../modules/virtual_machine/"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    network_subnets = {
      private = "subnet-id-private"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}
inputs = merge(
  local.common_vars.locals.common_vars,
  {
    subnet_id = dependency.network.outputs.network_subnets["private"]
    # admin_ssh_key_public_key intentionally not set here — leaving it unset
    # lets TF_VAR_admin_ssh_key_public_key (or -var) pass through to the
    # module; setting it here would override both via terragrunt's -var flag.
    vm_config = {
      name           = "private-vm"
      size           = "Standard_B1s"
      admin_username = "adminuser"
      public_ip      = false
      os_image = {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
      }
    }
  }
)
