
#### custom role for Data Services ###
locals {
  merged_actions = distinct(concat(
                              var.enable_dw ? var.dw_actions : [],
                              var.enable_liftie ? var.liftie_actions : [],
                              var.enable_de ? var.de_actions : []
                              )
                           )
}
resource "azurerm_role_definition" "ds" {
  count       = var.create_custom_role ? 1:0
  name        = var.custom_role_name
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom role for Cloudera Data Services"

  permissions {
    actions     = local.merged_actions

  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}", # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}