
#### custom role for Data Services ###
module "custom_role_permissions" {
  source          = "github.com/nicknameyu/cdp-prerequisite-module/azure/cdp-custom-role-permissions"
  enable_cmk_rbac = var.enable_cmk_rbac
  enable_dw       = var.enable_dw
  enable_liftie   = var.enable_liftie
}

resource "azurerm_role_definition" "ds" {
  count       = var.create_custom_role ? 1:0
  name        = var.custom_role_name
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom role for Cloudera Data Services"

  permissions {
    actions      = module.custom_role_permissions.mi_permissions.actions
    data_actions = module.custom_role_permissions.mi_permissions.data_actions

  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}", # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}