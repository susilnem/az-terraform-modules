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
  source = "../../../modules/az_aks/"
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    subnets = {
      public = "subnet-id-public"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}
inputs = merge(
  local.common_vars.locals.common_vars,
  {
    subnet_id = dependency.network.outputs.subnets["public"]
    aks_config = {
      name       = "aks-example"
      dns_prefix = "aksexample"
      default_node_pool = {
        name                 = "default"
        vm_size              = "Standard_B2s"
        auto_scaling_enabled = true
        min_count            = 1
        max_count            = 3
      }
      network_profile = {
        network_plugin = "azure"
        network_policy = "azure"
      }
    }
  }
)
