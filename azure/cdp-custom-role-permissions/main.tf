locals {
  custom_actions = distinct(concat(
                                    var.env_reduced_permission_actions,
                                    var.enable_dw ? var.dw_actions : [],
                                    var.enable_liftie ? var.liftie_actions : [],
                                    var.enable_de ? var.de_actions : [],
                                    var.enable_cmk ? var.cmk_rbac_actions : []
                                    )
                           )
  custom_data_actions = distinct(concat(var.env_reduced_permission_data_actions, var.enable_cmk ? var.cmk_rbac_data_actions : []))
}

output "custom_permissions" {
  value = {
    actions      = local.custom_actions
    data_actions = local.custom_data_actions
  }
}