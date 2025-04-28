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
  source = "../../../modules/az_network"
}

inputs = merge(
    local.common_vars.locals.common_vars,
    {
      # Virtual Network Configuration
      vnet_config = {
        name          = "vnet-example"
        address_space = ["10.0.0.0/16"]
      }
      # Subnet Configuration
      subnet_configs = {
        public = {
          address_prefixes = ["10.0.1.0/24"]
        }
        private = {
          address_prefixes = ["10.0.2.0/24"]
        }
      }
      # Network Security Group Configuration
      nsg_configs = {
        public = {
          security_rules = [
            {
              name                       = "SSH"
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "22"
              source_address_prefix      = "*"
              destination_address_prefix = "*"
            }
          ]
        }
        private = {
          security_rules = [
            {
              name                       = "SSH-from-public"
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "22"
              source_address_prefix      = "10.0.1.0/24"
              destination_address_prefix = "*"
            }
          ]
        }
      }
      # Route Table Configuration
      route_table_configs = {
        public = {
          routes = [
            {
              name           = "default-route"
              address_prefix = "0.0.0.0/0"
              next_hop_type  = "Internet"
            }
          ]
        }
        private = {
          routes = []
        }
      }
    }
)
