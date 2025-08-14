
### Data Warehouse Custom Role Assignment #########
locals {
  resource_id_parts = split("/", var.managed_identity_id)

  resource_group_name = element(local.resource_id_parts, 4)
  managed_identity_name = element(local.resource_id_parts, length(local.resource_id_parts) - 1) 

}
data "azurerm_user_assigned_identity" "dataaccess" {
  resource_group_name = local.resource_group_name
  name = local.managed_identity_name
}

locals {
  role_assignment = var.custom_role_name == null ? null : {
    ds1  = {
      principal_id = data.azurerm_user_assigned_identity.dataaccess.principal_id
      scope = "/subscriptions/${var.subscription_id}"
      role  = var.custom_role_name
    },
    ds2 = {                                                                                     // Attention: this one is not listed in document, but it is necessary
      principal_id = data.azurerm_user_assigned_identity.dataaccess.principal_id
      scope = "/subscriptions/${var.subscription_id}"
      role  = "Managed Identity Operator"
    }
  }
}

resource "time_sleep" "custom_role" {
  count = var.create_custom_role ? 1:0
  // Adding this sleep resource to create a delay between creating the custom roles and role assignment.
  depends_on =  [local.sleep_dependency]

  create_duration = "300s"
}
locals {
  sleep_dependency = var.create_custom_role ? azurerm_role_definition.ds : null

  custom_role_assign_dependency = var.create_custom_role ?  time_sleep.custom_role[0] : null
}
resource "azurerm_role_assignment" "ds" {
  for_each             = local.role_assignment
  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
  principal_id         = each.value["principal_id"]
  depends_on = [ local.custom_role_assign_dependency ]
}

