## tenant and scope
variable "subscription_id" {
  type = string
  description = "Azure subscriptino ID for the scope of the resources."
}

variable "tenant_id" {
  type = string
  description = "Tenant ID of this AzureAD"
}

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
  validation {
    condition     = var.create_spn && var.spn_app_name != null || ! var.create_spn
    error_message = "When `create_spn` is set to true, `spn_app_name` must be provided."
  }
}
variable "create_spn" {
  type = bool
  default = false
  description = "To indicate wether the SPN has been created already. When set to false(default), no new SPN will be created; when set to true, a new SPN will be created. "
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
  description = "Whether to create the custom role with name provided by `custom_role_name`. "
}

## Permissions
variable "enable_dw" {
  type = bool
  default = true
  description = "Enable DW permissions. Default to true."
}
variable "enable_cmk_rbac" {
  type = bool
  default = true
  description = "Enable CMK permissions. Default to true."
}

variable "enable_liftie" {
  type = bool
  default = true
  description = "Enable Liftie permissions. Default to true."
}

variable "enable_de" {
  type = bool
  default = true
  description = "Enable Liftie permissions. Default to true."
}