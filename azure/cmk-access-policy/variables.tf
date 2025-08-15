variable "subscription_id" {
  type        = string
  description = "Subscription ID of the key vault. "
}
variable "location" {
  type = string
  default = null
  description = "Azure region for the new create Key Vault. "
  validation {
    condition = var.create_keyvault && var.location != null || ! var.create_keyvault
    error_message = "When `create_keyvault` is set to true, `location` can't be empty. "
  }
}

variable "create_keyvault" {
  type    = bool
  default = true
  description = "Switch for whether to create the Key Vault. "
}

variable "key_vault_name" {
  type = string
  description = "Name of the key vault."
}

variable "resource_group_name" {
  type = string
  description = "Name of the resource group that hold the key vault. "
}

variable "key_name" {
  type = string
  description = "Name of the key. If provided, a new key will be created. "
  default = null
}

variable "spn_object_id" {
  type = string
  description = "The SPN object ID to be granted the access policy."
}

variable "managed_identity_id" {
  type = string
  description = "The principal ID of the managed identity. "
}


variable "tags" {
  type = map(string)
  default = null
}

variable "storage_account_id" {
  type = string
  default = null
  description = "The ID of the storeage account to be encrypted with the CMK."
}

variable "enable_rbac_authorization" {
  default = false
  type = bool
  description = "Control rbac authentication if it is a new created key vault. "
}