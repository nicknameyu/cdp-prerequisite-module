// DNS Zone RBAC must be at least be assigned at resource group level, because there are multiple private DNS zones in a CDP deployment.

locals {
  dns_zone_subscription_id = var.private_dns_zone_resource_group_id == null ? null : split("/", var.private_dns_zone_resource_group_id)[2]
  // If `private_dns_zone_resource_group_id` is not provided, do not need this role assignment.
  // If `private_dns_zone_resource_group_id` is in the same subscription as the CDP subscription, and the RBAC is at subscription level, do not need this role assignment.
  dns_zone_assignment      = var.private_dns_zone_resource_group_id == null ? {} : (
                                  local.scope_level == "SUBSCRIPTION" && local.subscription_id == local.dns_zone_subscription_id ? {}:local.principals)
}
provider "azurerm" {
  alias           = "dns_zone"
  subscription_id = var.private_dns_zone_resource_group_id == null ? local.subscription_id : local.dns_zone_subscription_id
  features {}
}
resource "azurerm_role_assignment" "dns_zone" {
  for_each             = local.dns_zone_assignment
  provider             = azurerm.dns_zone
  principal_id         = each.value
  scope                = var.private_dns_zone_resource_group_id
  role_definition_name = "Private DNS Zone Contributor"
}