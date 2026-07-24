mock_provider "azurerm" {}

# azurerm validates the *shape* of ID-typed arguments (e.g. subnet_id) at plan
# time regardless of provider mocking, so downstream association resources
# need realistically-shaped mock IDs from their upstream resources.
override_resource {
  target = azurerm_subnet.subnet
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/public"
  }
}

override_resource {
  target = azurerm_network_security_group.nsg
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg-public"
  }
}

override_resource {
  target = azurerm_route_table.route_table
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/routeTables/rt-public"
  }
}

variables {
  resource_group_name = "rg-test"
  location            = "eastus"

  vnet_config = {
    name          = "vnet-test"
    address_space = ["10.0.0.0/16"]
  }

  subnet_configs = {
    public = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }

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
  }

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
  }
}

run "valid_config_plans_successfully" {
  command = plan
}

run "rejects_invalid_location" {
  command = plan
  variables {
    location = "East US"
  }
  expect_failures = [var.location]
}

run "rejects_invalid_vnet_cidr" {
  command = plan
  variables {
    vnet_config = {
      name          = "vnet-test"
      address_space = ["not-a-cidr"]
    }
  }
  expect_failures = [var.vnet_config]
}

run "rejects_invalid_subnet_cidr" {
  command = plan
  variables {
    subnet_configs = {
      public = {
        address_prefixes = ["not-a-cidr"]
      }
    }
  }
  expect_failures = [var.subnet_configs]
}

run "rejects_nsg_priority_out_of_range" {
  command = plan
  variables {
    nsg_configs = {
      public = {
        security_rules = [
          {
            name                       = "SSH"
            priority                   = 5000
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
    }
  }
  expect_failures = [var.nsg_configs]
}

run "rejects_invalid_route_next_hop_type" {
  command = plan
  variables {
    route_table_configs = {
      public = {
        routes = [
          {
            name           = "bad-route"
            address_prefix = "0.0.0.0/0"
            next_hop_type  = "NotARealHopType"
          }
        ]
      }
    }
  }
  expect_failures = [var.route_table_configs]
}

run "rejects_nsg_key_not_in_subnet_configs" {
  command = plan
  variables {
    nsg_configs = {
      typo_key = {
        security_rules = []
      }
    }
  }
  expect_failures = [check.nsg_and_route_table_keys_match_subnets]
}
