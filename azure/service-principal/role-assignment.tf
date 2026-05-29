locals {
  role_assignments = {
    for pair in setproduct(keys(local.principals), keys(local.scope)) :
    "${pair[0]}__${pair[1]}" => {
      principal_id = local.principals[pair[0]]
      scope        = local.scope[pair[1]]
    }
  }
}
resource "azurerm_role_assignment" "cdp" {
  for_each             = local.role_assignments
  scope                = each.value.scope
  role_definition_name = var.custom_role_name == null ? "Contributor" : var.custom_role_name
  principal_id         = each.value.principal_id
  depends_on           = [ time_sleep.custom_role ]
}

locals {
  sleep_dependency = var.create_custom_role ? [ azurerm_role_definition.reduced[0] ]: []
}
# When custom role is to be created, Azure usually needs 5 mins to sync the new created custom role to Entra AD. 
resource "time_sleep" "custom_role" {
  depends_on      = [local.sleep_dependency]
  create_duration = var.create_custom_role ? "300s" : "1s"
}


module "custom_role_permissions" {
  source          = "github.com/nicknameyu/cdp-prerequisite-module/azure/cdp-custom-role-permissions"
  enable_cmk      = var.key_vault_id != null
  enable_dw       = var.enable_dw
  enable_liftie   = var.enable_liftie
  enable_de       = var.enable_de
}

resource "azurerm_role_definition" "reduced" {
  count       = var.create_custom_role ? 1:0
  name        = var.custom_role_name
  scope       = "/subscriptions/${local.subscription_id}"
  description = "Custom role for CDP provisioning with reduced permission."


  permissions {
    actions     = module.custom_role_permissions.custom_permissions.actions
    data_actions = module.custom_role_permissions.custom_permissions.data_actions
  }

  assignable_scopes = [
    "/subscriptions/${local.subscription_id}", # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}