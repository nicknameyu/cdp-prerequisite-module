variable "storage_account_ids" {
  type = map(string)
  description = "A map of storage account IDs to be encrypted."
}
variable "key_vault_key_id" {
  type = string
  description = "Auzre Key Vault Key ID"
}
variable "managed_identity_id" {
  type = string
  description = "Managed identity ID for the encryption"
}
resource "azurerm_storage_account_customer_managed_key" "cdp" {
  for_each                  = var.storage_account_ids
  storage_account_id        = each.value
  key_vault_key_id          = var.key_vault_key_id
  user_assigned_identity_id = var.managed_identity_id
}
