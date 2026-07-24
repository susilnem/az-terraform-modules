# Terragrunt defaults to `tofu` if both tofu and terraform are on PATH;
# force terraform explicitly to match mise.toml and the pinned CI toolchain.
terraform_binary = "terraform"

# Local backend for `validate`, which never needs real Azure state or credentials
# (set TG_LOCAL_BACKEND=true, e.g. in CI's validate job). Defaults to the real
# azurerm backend for everything else (plan/apply/destroy).
locals {
  use_local_backend = get_env("TG_LOCAL_BACKEND", "false") == "true"

  local_backend = <<EOF
  terraform {
    backend "local" {}
  }
  EOF

  azurerm_backend = <<EOF
  terraform {
    backend "azurerm" {
      resource_group_name  = "susilnemterraformstate-rg"
      storage_account_name = "susilnemtfstate"
      container_name       = "terraform"
      key                  = "${path_relative_to_include()}/terraform.tfstate"
    }
  }
  EOF
}

# Generate a backend configuration file for the root module
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.use_local_backend ? local.local_backend : local.azurerm_backend
}

# Generate the provider config for every unit.
# required_version/required_providers live in each module's versions.tf so
# `tflint` (which lints module source directly, without this generate block)
# still sees them; generating them here too would duplicate the block.
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}
