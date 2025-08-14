resource "azurerm_role_assignment" "xaccount" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = var.custom_role_name == null ? "Contributor" : var.custom_role_name
  principal_id         = local.spn_object_id
  depends_on = [ time_sleep.custom_role ]
}

locals {
  sleep_dependency = var.create_custom_role ? [ azurerm_role_definition.reduced[0] ]: []
}
resource "time_sleep" "custom_role" {
  depends_on      = [local.sleep_dependency]
  create_duration = var.create_custom_role ? "300s" : "1s"
}


module "custom_role_permissions" {
  source          = "../cdp-custom-role-permissions"
  enable_cmk_rbac = var.enable_cmk_rbac
  enable_dw       = var.enable_dw
  enable_liftie   = var.enable_liftie
  enable_de       = var.enable_de
}

resource "azurerm_role_definition" "reduced" {
  count       = var.create_custom_role ? 1:0
  name        = var.custom_role_name
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom role for CDP Datahub provisioning with reduced permission."


  permissions {
    actions     = module.custom_role_permissions.spn_permissions.actions
    data_actions = module.custom_role_permissions.data_actions
  }

  assignable_scopes = [
    "subscriptions/${var.subscription_id}", # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}