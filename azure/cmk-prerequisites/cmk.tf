




resource "azurerm_key_vault" "kv" {
  count                      = var.cmk == null ? 0:1
  name                       = var.cmk.kv_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_subscription.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_subscription.current.tenant_id
    object_id = var.cmk.spn_object_id

    key_permissions = [
      "List",
      "Get",
    ]

    secret_permissions = [
      "Set",
    ]
  }
  access_policy {
    tenant_id = data.azurerm_subscription.current.tenant_id
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

    secret_permissions = [
      "Set",
    ]
  }
  lifecycle {
    ignore_changes = [ access_policy ]
  }
  
}

resource "azurerm_key_vault_key" "default" {
  count        = var.cmk == null ? 0:1
  name         = "cdp-default-key"
  key_vault_id = azurerm_key_vault.kv[0].id
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
}

output "cmk_key_id" {
  value = var.cmk == null ? null : azurerm_key_vault_key.default[0].id
}
