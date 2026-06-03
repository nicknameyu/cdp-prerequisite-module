locals {
  kv_subscription_id = var.kv_subscription_id == null ? data.azurerm_subscription.current.subscription_id : var.kv_subscription_id
}
provider "azurerm" {
  alias           = "kv"
  subscription_id = local.kv_subscription_id
  features {}
}

resource "azurerm_role_assignment" "spn_kv" {
  count                = var.key_vault_id == null ? 0 : 1
  principal_id         = var.spn_object_id
  provider             = azurerm.kv
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

resource "azurerm_role_assignment" "mi_kv" {
  count                = var.key_vault_id == null || var.mi_object_id == null ? 0 : 1
  principal_id         = var.mi_object_id
  provider             = azurerm.kv
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}