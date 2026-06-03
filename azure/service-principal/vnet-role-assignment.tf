# VNET role assignment logic.
# - Major consideration other than the scope variable: There is a scope variable `var.vnet_resource_group_id`. But sometimes we can't set the permission at resource group level for this 
#   consideration: When data service is enabled, AKS will be created, and a compute resource group will be created. If the CMK_DS managed identity is being used for 
#   the management principal, the MI will be used to create the compute resource group, so the MI will have contributor permision on the new created resource group, but the provisioning 
#   will fail because liftie will still try to use SPN to read the security groups created in the compute resource group. To resolve this conflict, SPN must have `Network Contributor` \
#   permission at subscription level.
# - If the calculated RBAC scope level `local.scope_level` is "SUBSCRIPTION", the SPN and MI both get the required network permision assignment at subscription level, then NO RBAC is 
#   required for VNET.
# - When `local.scope_level` is "RESOURCEGROUP":
#   - When `vnet_resource_group_id` variable is null: VNET permission must be at subscription level.
#   - When `vnet_resource_group_id` variable points to a resource group: 
#     - If `var.mi_object_id` is null, SPN need permission assignment at resource group level. It doesn't matter whethe DS is enabled, cause the AKS will be created by SPN. 
#     - if `var.mi_object_id` is not null:
#       - If DS is not enabled, VNET permission is granted at resource group level.
#       - If DS is enabled: VNET permission is granted at subscription level.

locals {
  enable_ds       = var.enable_dw || var.enable_de || var.enable_liftie
  force_sub_rbac  = local.enable_ds && (var.mi_object_id != null )

  # Resolve VNET RBAC scope:
  # - Subscription level if force_sub_rbac is true (DS enabled + MI in use)
  # - Subscription level if vnet_resource_group_id is null (no RG scoping possible)
  # - Otherwise, use the provided resource group
  vnet_rbac_scope = (local.force_sub_rbac || var.vnet_resource_group_id == null) ? data.azurerm_subscription.current.id : var.vnet_resource_group_id

  # Skip VNET assignment entirely when scope_level is SUBSCRIPTION, because
  # SPN and MI already received network permissions at subscription level via
  # the broader scope assignment — no additional VNET assignment needed.
  vnet_assignment = length(var.rbac_scope) == 0 ? {} : local.principals
}
resource "azurerm_role_assignment" "vnet" {
  for_each             = local.vnet_assignment
  principal_id         = each.value
  scope                = local.vnet_rbac_scope
  role_definition_name = "Network Contributor"
}