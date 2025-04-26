terraform {
  backend "azurerm" {
    resource_group_name  = "susilnemterraformstate-rg"
    storage_account_name = "susilnemtfstate"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}
