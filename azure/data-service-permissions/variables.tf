variable "custom_role_name" {
  type = string
  description = "Name of DataWarehouse Custom role. Required if DataWarehouse is in the deployment. If create_dw_custom_role is false and this value is not null, this module will look for existing DataWareHouse custom role. If create_dw_custom_role is true, this module will create the DataWarehouse custom role in this name. "
  default = null
}
variable "create_custom_role" {
  type = bool
  description = "Control whether to create DW custom role"
  default = false
}
variable "subscription_id" {
  type = string
  description = "Azure subscriptino ID to be used to deploy the resources."
}
variable "mi_principal_id" {
  type = string
  description = "Data access managed identity principal ID to be granted the DW custom role."
}


######## Default permissions ##########
variable "enable_dw" {
  type = bool
  default = true
  description = "Enable DW permissions. Default to true."
}

variable "enable_liftie" {
  type = bool
  default = true
  description = "Enable Liftie permissions. Default to true."
}
variable "enable_cmk_rbac" {
  type = bool
  default = true
  description = "Enable CMK permission for RBAC. Default to true."
}
