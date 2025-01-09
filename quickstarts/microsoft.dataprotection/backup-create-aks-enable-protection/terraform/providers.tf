terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.99.0"
    }
  }
}

provider "azurerm" {
   features {}
   subscription_id   = "<azure_subscription_id>"
   tenant_id = "<azure_subscription_tenant_id>"
}