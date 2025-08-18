############## universal variables ############
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

variable "tags" {
  type = map(string)
  default = null
}

############### Key Vault resource variables ###############
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
}

############### Permission control variables ##############
variable "spn_object_id" {
  type = string
  description = "The SPN object ID to be granted the access policy."
  default = null
  validation {
    condition     = var.enable_access_policy == false || (var.enable_access_policy == true && var.spn_object_id != null && length(trim(var.spn_object_id)) > 0)
    error_message = "spn_object_id cannot be null or empty when enable_access_policy is true."
  }
}

variable "managed_identity_id" {
  type = string
  description = "The principal ID of the managed identity. "
  default = null
  validation {
    condition     = var.enable_access_policy == false || (var.enable_access_policy == true && var.managed_identity_id != null)
    error_message = "managed_identity_id cannot be null or empty when enable_access_policy is true."
  }
  validation {
    condition     = var.storage_account_id == null || (var.storage_account_id != null && var.managed_identity_id != null)
    error_message = "managed_identity_id cannot be null or empty when storage_account_id is not null. Cause storage account CMK encryption must be configured with a managed identity."
  }
}


## RBAC and Access policy control
## SPN RBAC is already granted in Service principal module. Managed Identity RBAC is granted in MI permission module. 
## So item to be decided is: Whether create access polocy.
## So we need below variables to cotrol dynamic resources: 
## - Need one variable to control whether to create access policies. This variable also controls whether to enable access policy authorization for the vault. 

variable "enable_access_policy" {
  default = false
  type = bool
  description = "Control whether to create access policy."
}

#############
variable "storage_account_id" {
  type = string
  default = null
  description = "The ID of the storeage account to be encrypted with the CMK. When provided, the storage account will be configured with CMK encryption."
}
