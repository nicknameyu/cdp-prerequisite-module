module "custom_role_permissions" {
  source          = "../"
  enable_cmk      = true
  enable_dw       = false
  enable_liftie   = true
  enable_de       = false
}

output "spn_permissions" {
  value = module.custom_role_permissions.spn_permissions
}
output "mi_permissions" {
  value = module.custom_role_permissions.mi_permissions
}
output "dns_zone_permissions" {
  value = module.custom_role_permissions.dns_zone_permissions
}