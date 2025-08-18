### Create access policies 
locals {
  resource_id_parts      = var.managed_identity_id == null ? [] : split("/", var.managed_identity_id)

  mi_resource_group_name = var.managed_identity_id == null ? "" : element(local.resource_id_parts, 4)
  managed_identity_name  = var.managed_identity_id == null ? "" : element(local.resource_id_parts, length(local.resource_id_parts) - 1) 

}
data "azurerm_user_assigned_identity" "mi" {
  count               = var.managed_identity_id == null ? 0:1
  resource_group_name = local.mi_resource_group_name
  name                = local.managed_identity_name
}
locals {

  access_policies = {
    spn   = {
      // Access policy for service principal
      object_id = var.spn_object_id
      key_permissions = [ "List", "Get", "Decrypt", "Encrypt", "WrapKey", "UnwrapKey", ]
      secret_permissions = [ "Set","Get", "List" ]
    }
    mi    = {
      // Access policy for managed identity
      object_id    = var.managed_identity_id == null ? "" : data.azurerm_user_assigned_identity.mi[0].principal_id
      key_permissions = [ "List", "Get", "Decrypt", "Encrypt", "WrapKey", "UnwrapKey", ]
      secret_permissions = [ "Set", "Get", "List"]  
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
      secret_permissions = [ "Set", "Get", "List" ]
    }
  }
}
resource "azurerm_key_vault_access_policy" "kv" {
  for_each     = var.enable_access_policy ? local.access_policies:{}
  key_vault_id = local.key_vault_id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = each.value.object_id

  key_permissions    = each.value.key_permissions
  secret_permissions = each.value.secret_permissions
}
