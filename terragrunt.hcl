# Configure the remote backend
remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    resource_group_name  = "susilnemterraformstate-rg"
    storage_account_name = "susilnemtfstate"
    container_name       = "terraform"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}


locals {
  azure_provider_config = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }
  }

  required_version = ">= 1.11.0"
}

provider "azurerm" {
  features {}
}
EOF
}

# Configure the Azure provider
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.azure_provider_config
}
