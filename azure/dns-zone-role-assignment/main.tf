module "custom_role_permissions" {
  source          = "github.com/nicknameyu/cdp-prerequisite-module/azure/cdp-custom-role-permissions"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
       configuration_aliases = [
         azurerm.dns_zone,
       ]
    }
  }
}

# provider "azurerm" {
#   alias = "dns_zone"
# }

data "azurerm_subscription" "current" {
  provider = azurerm.dns_zone
}
resource "azurerm_role_definition" "dns_zone" {
  count       = var.use_custom_role ? 1:0
  name        = var.custom_role_name
  scope       = data.azurerm_subscription.current.id
  description = "CDP Cross subscription DNS Zone operator role"
  permissions {
    actions     = module.custom_role_permissions.dns_zone_permissions
  }
  assignable_scopes = [
    data.azurerm_subscription.current.id # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}
resource "azurerm_role_assignment" "dns_zone" {
  for_each             = var.principal_ids
  principal_id         = each.value
  scope                = var.assign_scope == null ? data.azurerm_subscription.current.id : var.assign_scope
  role_definition_name = var.use_custom_role ? azurerm_role_definition.dns_zone[0].name : "Private DNS Zone Contributor"
}