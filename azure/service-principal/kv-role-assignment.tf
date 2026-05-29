locals {

  kv_subscription_id = var.key_vault_id == null ? null : split("/", var.key_vault_id)[2]
  // If `key_vault_id` is not provided, do not need this role assignment.
  // If `key_vault_id` is in the same subscription as the CDP subscription, and the RBAC is at subscription level, do not need this role assignment.
  kv_assignment      = var.key_vault_id == null ? {} : (
                                  local.scope_level == "SUBSCRIPTION" && local.subscription_id == local.kv_subscription_id ? {}:local.principals)
}
provider "azurerm" {
  alias           = "kv"
  subscription_id = var.key_vault_id == null ? local.subscription_id : local.kv_subscription_id
  features {}
}
resource "azurerm_role_assignment" "kv" {
  for_each             = local.kv_assignment
  principal_id         = each.value
  provider             = azurerm.kv
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
}

