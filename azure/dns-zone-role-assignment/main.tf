module "custom_role_permissions" {
  source          = "github.com/nicknameyu/cdp-prerequisite-module/azure/cdp-custom-role-permissions"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {  }
}

resource "azurerm_role_definition" "dns_zone" {
  name        = var.custom_role_name
  scope       = "/subscriptions/${var.subscription_id}"
  provider    = azurerm
  description = "CDP Cross subscription DNS Zone operator role"
  permissions {
    actions     = module.custom_role_permissions.dns_zone_permissions
  }
  assignable_scopes = [
    "/subscriptions/${var.subscription_id}" # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}
resource "azurerm_role_assignment" "dns_zone" {
  for_each             = var.principal_ids
  principal_id         = each.value
  scope                = var.assign_scope == null ? "/subscriptions/${var.subscription_id}" : var.assign_scope
  role_definition_name = azurerm_role_definition.dns_zone.name
}