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
  source = "../../../modules/aks/"
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
    aks_config = {
      name       = "aks-testing"
      dns_prefix = "akstesting"
      default_node_pool = {
        name                 = "default"
        vm_size              = "Standard_B2s"
        auto_scaling_enabled = false
        node_count           = 1
      }
      network_profile = {
        network_plugin = "azure"
        network_policy = "azure"
        # Must not overlap the VNet's own address space (10.0.0.0/16).
        service_cidr   = "172.16.0.0/16"
        dns_service_ip = "172.16.0.10"
      }
      authorized_ip_ranges = ["110.34.1.108/32"]
    }
  }
)
