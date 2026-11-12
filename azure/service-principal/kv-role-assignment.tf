locals {
  kv_subscription_id = var.kv_subscription_id == null ? data.azurerm_subscription.current.subscription_id : var.kv_subscription_id
}
provider "azurerm" {
  alias           = "kv"
  subscription_id = local.kv_subscription_id
  features {}
}

resource "azurerm_role_assignment" "spn_kv" {
  for_each             = ! var.key_vault_rbac ? {}:{
                                                      Officer     = "Key Vault Crypto Officer"
                                                      Contributor = "Key Vault Contributor"
                                                    }
  principal_id         = var.spn_object_id
  provider             = azurerm.kv
  scope                = var.key_vault_id
  role_definition_name = each.value
}

resource "azurerm_role_assignment" "mi_kv" {
  for_each          = !var.key_vault_rbac ? {}:{
                                                  Officer     = "Key Vault Crypto Officer"
                                                  Contributor = "Key Vault Contributor"
                                                }
  principal_id         = var.mi_object_id
  provider             = azurerm.kv
  scope                = var.key_vault_id
  role_definition_name = each.value
}