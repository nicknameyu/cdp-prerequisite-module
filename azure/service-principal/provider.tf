provider "azurerm" {
  subscription_id = var.subscription_id
  features {

  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.4.0"
    }
  }
}

