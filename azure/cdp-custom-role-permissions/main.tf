locals {
  spn_reduced_actions = distinct(concat(
                                    var.env_reduced_permission_actions,
                                    var.enable_dw ? var.dw_actions : [],
                                    var.enable_liftie ? var.liftie_actions : [],
                                    var.enable_de ? var.de_actions : []
                                    )
                           )
  spn_reduced_data_actions = distinct(concat(var.env_reduced_permission_data_actions, var.enable_cmk_rbac ? var.cmk_rbac_data_actions : []))
  mi_actions  = distinct(concat(
                              var.enable_dw ? var.dw_actions : [],
                              var.enable_liftie ? var.liftie_actions : []
                              )
                         )
  mi_data_actions = distinct(concat(var.env_reduced_permission_data_actions, var.enable_cmk_rbac ? var.cmk_rbac_data_actions : []))
}

output "spn_permissions" {
  value = {
    actions      = local.spn_reduced_actions
    data_actions = local.spn_reduced_data_actions
    scope        = "CDP Subscription"
  }
}
output "mi_permissions" {
  value = {
    actions      = local.mi_actions
    data_actions = local.mi_data_actions
    scope        = "CDP Subscription"
  }
}
output "spn_buildin_role" {
  value = concat( 
      var.enable_cmk_rbac ? [{ role_name = "Key Vault Crypto User", scope = "CDP Subscription" }] : [] ,
      var.enable_dns_zone_subscription ?  [{role_name = "Private DNS Zone Contributor", scope = "Private DNS Zone Subscription" }]: [])
}
output "mi_buildin_role" {
  value = concat( 
      var.enable_cmk_rbac ? [{ role_name = "Key Vault Crypto User", scope = "CDP Subscription" }] : [] ,
      var.enable_dns_zone_subscription ?  [{role_name = "Private DNS Zone Contributor", scope = "Private DNS Zone Subscription" }]: [])
}
output "dns_zone_permissions" {
  value       = var.dns_zone_actions
}