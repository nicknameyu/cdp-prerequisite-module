
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
variable "use_custom_role" {
  default = false
  type = bool
  description = "Switch of using build-in role or custom role. Default to false."
}