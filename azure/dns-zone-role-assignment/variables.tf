variable "subscription_id" {
  type = string
  description = "Azure subscriptino ID to be used to deploy the resources."
}
variable "custom_role_name" {
  type = string
  default = null
}
variable "principal_ids" {
  type = map(string)
  description = "Map of principal ids to be assigned the role. Better to give two principals: Service Principal and the Managed Identity. {spn=\"SPN object ID\", mi=\"MI principal id\"}"
}
variable "assign_scope" {
  type = string
  default = null
  description = "Assign scope of the DNS zone role. Default to subscription level. "
}