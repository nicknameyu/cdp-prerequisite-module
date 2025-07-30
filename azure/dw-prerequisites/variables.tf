variable "dw_custom_role" {
  type = string
  description = "Name of DataWarehouse Custom role. Required if DataWarehouse is in the deployment. If create_dw_custom_role is false and this value is not null, this module will look for existing DataWareHouse custom role. If create_dw_custom_role is true, this module will create the DataWarehouse custom role in this name. "
  default = null
}
variable "create_dw_custom_role" {
  type = bool
  description = "Control whether to create DW custom role"
  default = false
}
variable "subscription_id" {
  type = string
  description = "Azure subscriptino ID to be used to deploy the resources."
}
variable "dataaccess_mi" {
  type = string
  description = "Data access managed identity to be granted the DW custom role."
}