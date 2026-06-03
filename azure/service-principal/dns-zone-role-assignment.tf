// DNS Zone RBAC must be at least be assigned at resource group level, because there are multiple private DNS zones in a CDP deployment.

locals {
  dns_zone_subscription_id = var.dns_zone_subscription_id == null ? data.azurerm_subscription.current.subscription_id : var.dns_zone_subscription_id
}
provider "azurerm" {
  alias           = "dns_zone"
  subscription_id = local.dns_zone_subscription_id
  features {}
}
resource "azurerm_role_assignment" "spn_dns_zone" {
  count                = var.private_dns_zone_resource_group_id == null ? 0 : (
    length(var.rbac_scope) == 0 && (data.azurerm_subscription.current.subscription_id == local.dns_zone_subscription_id ) ? 0:1)
  provider             = azurerm.dns_zone
  principal_id         = var.spn_object_id
  scope                = var.private_dns_zone_resource_group_id
  role_definition_name = "Private DNS Zone Contributor"
}

resource "azurerm_role_assignment" "mi_dns_zone" {
  count                = var.private_dns_zone_resource_group_id == null || var.mi_object_id == null ? 0 : (
    length(var.rbac_scope) == 0 && (data.azurerm_subscription.current.subscription_id == local.dns_zone_subscription_id ) ? 0:1)
  provider             = azurerm.dns_zone
  principal_id         = var.mi_object_id
  scope                = var.private_dns_zone_resource_group_id
  role_definition_name = "Private DNS Zone Contributor"
}