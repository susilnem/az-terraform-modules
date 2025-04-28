# Generate a backend configuration file for the root module
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  terraform {
    backend "azurerm" {
      resource_group_name  = "susilnemterraformstate-rg"
      storage_account_name = "susilnemtfstate"
      container_name       = "terraform"
      key                  = "terraform.tfstate"
    }
  }
  EOF
}
