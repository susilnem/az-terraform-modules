# Generate a backend configuration file for the root module
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
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

# Generate the provider requirements + config for every unit
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81.0"
    }
  }
}

provider "azurerm" {
  features {}
}
EOF
}
