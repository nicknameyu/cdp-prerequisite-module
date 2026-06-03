

data azurerm_subscription "current"{}
data "azurerm_client_config" "current" {}
provider "azurerm" {
  alias           = "kv"
  subscription_id = var.subscription_id
  features {}
}