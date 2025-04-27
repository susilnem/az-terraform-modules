# https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.11.0/docs/rules/terraform_required_version.md
config {
  call_module_type = "all"
}

plugin "terraform" {
    enabled = true
    version = "0.12.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

plugin "azurerm" {
    enabled = true
    version = "0.23.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# FIXME: USE rules to overide the warnings
# Overriding the terraform_required_version
rule "terraform_required_version" {
  enabled = false
}
# Overriding the terraform_required_providers
rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_documented_outputs" {
  enabled = false
}
