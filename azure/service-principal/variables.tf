
## SPN
variable "spn_object_id" {
  description = "The object ID of the existing SPN. When not provided(default), app_name variable must be provided, and a new SPN will be created."
  type = string
  default = null
  validation {
    condition     = (var.spn_object_id != null && var.spn_app_name == null) || (var.spn_object_id == null && var.spn_app_name != null) 
    error_message = "Either `spn_object_id` or `spn_app_name` must be set."
  }
}
variable "spn_app_name" {
  type = string
  default = null
  description = "The name of the app to be created. If provided, a new app will be created. If not provided, spn_object_id must be provided for the module to retrieve the existing SPN."
  # validation {
  #   condition     = var.create_spn && var.spn_app_name != null || ! var.create_spn
  #   error_message = "When `create_spn` is set to true, `spn_app_name` must be provided."
  # }
}
# variable "create_spn" {
#   type = bool
#   default = false
#   description = "To indicate wether the SPN has been created already. When set to false(default), no new SPN will be created; when set to true, a new SPN will be created. "
# }

## Managed identity is being used for CMK, and AKS admin. It share the same permission with the SPN.
variable "mi_object_id" {
  type = string
  default = null
  description = "Object ID of the CMK and Data Service managed identity to be used in the CDP environment. When provided, it will be assigned with the same permissions as the SPN."
}

## Role assignment
variable "custom_role_name" {
  type = string
  default = null
  description = "The name of the custom role for reduced permission. When not provided, `Contributor` role will be granted to the SPN. "
  validation {
    condition     = (var.create_custom_role && var.custom_role_name != null) || ! var.create_custom_role
    error_message = "When `create_custom_role` is true, `custom_role_name` must be provided. "
  }
}
variable "create_custom_role" {
  type = bool
  default = false
  description = "Whether to create the custom role with name provided by `custom_role_name`. Default to false, and `contributor` permission will be assigned."
}

## Permissions
variable "enable_dw" {
  type = bool
  default = false
  description = "Enable DW permissions. Default to true. Default to false because contributor permission is default setting. "
}

variable "enable_de" {
  type = bool
  default = false
  description = "Enable Liftie permissions. Default to false because contributor permission is default setting."
}
variable "enable_liftie" {
  type = bool
  default = false
  description = "Enable Liftie permissions. Default to false because contributor permission is default setting."
}

## Subscription IDs for KeyVault and private DNS zone.
## Theoretically speaking, these subscription IDs can be calculated by the `key_vault_id`, `scope`, and `private_dns_zone_resource_group_id` variables. But in some circumstances, these
## variables are generated from output of other resources, which make it impossible for terraform to calculate the value in this module at the planning stage. 
variable "kv_subscription_id" {
  type = string
  default = null
  description = "Key Vault subscription ID. Default to null. When set to `null`, the key vault is in the same subscription with the CDP resources."
}
variable "dns_zone_subscription_id" {
  type = string
  default = null
  description = "Private DNS zone subscription ID. Default to null. When set to `null`, the private DNS zone resource group is in the same subscription with the CDP resources."
}

## Permissions on supporting resources.
variable "key_vault_id" {
  type = string
  default = null
  description = "The resource ID of the Key Vault. When provided, CMK related RBAC will be granted to the key vault. "
}

variable "vnet_resource_group_id" {
  type = string
  default = null
  description = "The resource ID of the VNET resource group. When provided, `Network contributor` permission will be assigned. "
}

variable "private_dns_zone_resource_group_id" {
  type = string
  default = null
  description = "The ID of the private DNS zone resource group. When provided, private DNS zone related RBAC will be granted to the key vault."
}

## Scope and permission calculation
  // The reason of designing this variable as a map is: there is the possibility that a customer may split the environment resources in two resource groups, 
  // one for prerequisite, and the other for compute resources. There are too many prerequisites resources in current environment setup. One resoruce group 
  // makes it very messy for administration purpose. 
variable "rbac_scope" {
  type        = map(string)
  default     = {}
  description = "Map of Azure resource group IDs for this module to assign the RBAC to. When empty, RBAC at subscription level."

  validation {
    condition = alltrue([
      for v in values(var.rbac_scope) :
      can(regex(
        "^/subscriptions/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/resourceGroups/[^/]+$",
        v
      ))
    ])
    error_message = "All values must be valid Azure resource group IDs in the format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}."
  }

  validation {
    condition = length(distinct([
      for v in values(var.rbac_scope) :
      regex(
        "/subscriptions/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})/",
        v
      )[0]
    ])) <= 1
    error_message = "All resource groups must belong to the same subscription."
  }
}
