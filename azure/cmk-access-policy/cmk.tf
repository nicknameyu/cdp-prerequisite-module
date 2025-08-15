

locals {
  resource_id_parts = split("/", var.managed_identity_id)

  resource_group_name = element(local.resource_id_parts, 4)
  managed_identity_name = element(local.resource_id_parts, length(local.resource_id_parts) - 1) 

}
data "azurerm_user_assigned_identity" "mi" {
  resource_group_name = local.resource_group_name
  name = local.managed_identity_name
}
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
  enable_rbac_authorization  = var.enable_rbac_authorization
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_subscription.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  tags                       = var.tags
}

### Role assignments
resource "azurerm_role_assignment" "cmk" {
  for_each             = var.enable_rbac_authorization ? {spn = var.spn_object_id, mi = data.azurerm_user_assigned_identity.mi.principal_id } : {}
  principal_id         = each.value
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Key Vault Crypto User"
}
### Create access policies 
locals {
  key_vault_id    = var.create_keyvault ? azurerm_key_vault.kv[0].id : data.azurerm_key_vault.kv[0].id
  access_policies = {
    spn   = {
      // Access policy for service principal
      object_id = var.spn_object_id
      key_permissions = [ "List", "Get", "Decrypt", "Encrypt", "WrapKey", "UnwrapKey", ]
      secret_permissions = [ "Set", ]
    }
    mi    = {
      // Access policy for managed identity
      object_id    = data.azurerm_user_assigned_identity.mi.principal_id
      key_permissions = [ "List", "Get", "Decrypt", "Encrypt", "WrapKey", "UnwrapKey", ]
      secret_permissions = [ "Set", ]  
    }
    owner = {
      // Access policy for current user.
      object_id = data.azurerm_client_config.current.object_id
      key_permissions = [
        "Create",
        "List",
        "Delete",
        "Get",
        "Purge",
        "Recover",
        "Update",
        "GetRotationPolicy",
        "SetRotationPolicy"
      ]
      secret_permissions = [ "Set",  ]
    }
  }
}
resource "azurerm_key_vault_access_policy" "kv" {
  for_each     = var.enable_rbac_authorization ? {}:local.access_policies
  key_vault_id = local.key_vault_id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = each.value.object_id

  key_permissions    = each.value.key_permissions
  secret_permissions = each.value.secret_permissions
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
  key_vault_id              = var.create_keyvault ? azurerm_key_vault.kv[0].id : data.azurerm_key_vault.kv[0].id
  key_name                  = azurerm_key_vault_key.default.name
  user_assigned_identity_id = var.managed_identity_id
}
