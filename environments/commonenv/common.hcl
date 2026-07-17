# Default values for all environments
locals {
  common_vars = {
    resource_group_name = "susilnem-local-test-rg"
    location            = "eastus"
    tags = {
      environment = "local"
      managed_by  = "terragrunt"
    }
  }
}
