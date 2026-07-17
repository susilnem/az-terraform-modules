mock_provider "azurerm" {}

# The mock provider defaults computed list/block attributes to empty, but
# identity/kubelet_identity are always single-element lists on a real
# cluster, and outputs.tf indexes into them ([0]) unconditionally.
override_resource {
  target = azurerm_kubernetes_cluster.aks
  values = {
    identity = {
      principal_id = "00000000-0000-0000-0000-000000000001"
      tenant_id    = "00000000-0000-0000-0000-000000000002"
    }
  }
}

variables {
  resource_group_name = "rg-test"
  location            = "eastus"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/public"

  aks_config = {
    name       = "aks-test"
    dns_prefix = "akstest"
    default_node_pool = {
      name       = "default"
      vm_size    = "Standard_B2s"
      node_count = 2
    }
  }
}

run "valid_fixed_node_count_plans_successfully" {
  command = plan
}

run "valid_autoscaling_config_plans_successfully" {
  command = plan
  variables {
    aks_config = {
      name       = "aks-test"
      dns_prefix = "akstest"
      default_node_pool = {
        name                 = "default"
        vm_size              = "Standard_B2s"
        auto_scaling_enabled = true
        min_count            = 1
        max_count            = 3
      }
    }
  }
}

run "rejects_autoscaling_without_min_max" {
  command = plan
  variables {
    aks_config = {
      name       = "aks-test"
      dns_prefix = "akstest"
      default_node_pool = {
        name                 = "default"
        vm_size              = "Standard_B2s"
        auto_scaling_enabled = true
      }
    }
  }
  expect_failures = [var.aks_config]
}

run "rejects_invalid_dns_prefix" {
  command = plan
  variables {
    aks_config = {
      name       = "aks-test"
      dns_prefix = "invalid dns prefix!"
      default_node_pool = {
        name       = "default"
        vm_size    = "Standard_B2s"
        node_count = 2
      }
    }
  }
  expect_failures = [var.aks_config]
}

run "rejects_invalid_vm_size" {
  command = plan
  variables {
    aks_config = {
      name       = "aks-test"
      dns_prefix = "akstest"
      default_node_pool = {
        name       = "default"
        vm_size    = "B2s"
        node_count = 2
      }
    }
  }
  expect_failures = [var.aks_config]
}

run "rejects_duplicate_additional_node_pool_names" {
  command = plan
  variables {
    aks_config = {
      name       = "aks-test"
      dns_prefix = "akstest"
      default_node_pool = {
        name       = "default"
        vm_size    = "Standard_B2s"
        node_count = 2
      }
      additional_node_pools = [
        {
          name       = "extra"
          vm_size    = "Standard_B2s"
          node_count = 1
        },
        {
          name       = "extra"
          vm_size    = "Standard_B2s"
          node_count = 1
        }
      ]
    }
  }
  expect_failures = [var.aks_config]
}

run "rejects_invalid_automatic_upgrade_channel" {
  command = plan
  variables {
    aks_config = {
      name       = "aks-test"
      dns_prefix = "akstest"
      default_node_pool = {
        name       = "default"
        vm_size    = "Standard_B2s"
        node_count = 2
      }
      automatic_upgrade_channel = "sometimes"
    }
  }
  expect_failures = [var.aks_config]
}
