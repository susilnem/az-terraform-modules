# Terraform setup and provider

terraform {
  required_providers {
    # Azure Resource Manager
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.23.0"
    }
  }
  required_version = ">1.11.0"
}

provider "azurerm" {
  features {}
}
