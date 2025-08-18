
#### Create or retrieve Key Vault ####

data "azurerm_key_vault" "kv" {
  count               = var.create_keyvault ? 0:1
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  lifecycle {
    postcondition {
      condition     = ! self.enable_rbac_authorization 
      error_message = "Key Vault must be configured with Access Policy for authorization."
    }
  }
}
resource "azurerm_key_vault" "kv" {
  count                      = var.create_keyvault ? 1:0
  name                       = var.key_vault_name
  location                   = var.location
  enable_rbac_authorization  = ! var.enable_access_policy
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_subscription.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
//  enabled_for_disk_encryption= true
  tags                       = var.tags
}
locals {
  key_vault_id    = var.create_keyvault ? azurerm_key_vault.kv[0].id : data.azurerm_key_vault.kv[0].id
}

### Create CMK
resource "azurerm_key_vault_key" "default" {
  name         = var.key_name
  key_vault_id = local.key_vault_id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
  depends_on = [ azurerm_key_vault_access_policy.kv ]
}

output "cmk_key_id" {
  value = azurerm_key_vault_key.default.id
}
output "cmk_key_vault_id" {
  value = var.create_keyvault ? azurerm_key_vault.kv[0].id : data.azurerm_key_vault.kv[0].id
}

#### Change the storage account setting
resource "azurerm_storage_account_customer_managed_key" "cdp" {
  count                     = var.storage_account_id == null ? 0 : 1
  storage_account_id        = var.storage_account_id
  key_vault_id              = local.key_vault_id
  key_name                  = azurerm_key_vault_key.default.name
  user_assigned_identity_id = var.managed_identity_id
}
