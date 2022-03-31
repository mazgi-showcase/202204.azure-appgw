# --------------------------------
# Terraform configuration

terraform {
  # https://www.terraform.io/downloads.html
  required_version = "=1.1.7"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.2"
    }
  }

  backend "azurerm" {
    container_name = "provisioning"
    key            = "default/terraform"
  }
}

provider "azurerm" {
  features {}
}
