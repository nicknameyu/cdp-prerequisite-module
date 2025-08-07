
##### General variables #####
variable "subscription_id" {
  type        = string
  description = "Subscription ID of the storage account. "
}
variable "location" {
  type = string
  description = "Azure region for the new create storage account. "
}
variable "tags" {
  type = map(string)
  default = null
  description = "Tags for the storage account. "
}

##### NFS parameter variables ##### 
variable "resource_group_name" {
  type = string
  description = "Name of the resource group that hold the storage account. "
}
variable "create_resource_group" {
  type = bool
  description = "To control whether to create a resource group to hole the file share storage account. Default to `false` because most users would prefer this storage to be in the same resource group with other prerequisite resources."
  default = false
}

variable "storage_account_name" {
  type = string
  description = "Name of the storage account. "
}

variable "file_share_name" {
  type = string
  description = "Name of the file share. "
}

variable "size" {
  type = number
  description = "Size of the fire share in GB. "
  default = 100
}

variable "account_tier" {
  type = string
  default = "Premium"
  description = "Storage account performance tier. Default to `Premium`. "
}

variable "replication" {
  type = string
  default = "LRS"
  description = "Replication tier of the storage account. Default to `LRS`."
}


##### Network variables #####
variable "subnet_ids" {
  type = list(string)
  default = null
  description = "Subnet IDs to be allowed."
}

variable "vnet_resource_group_name" {
  type = string
  default = null
  validation {
    condition     = var.subnet_ids != null && var.vnet_resource_group_name == null || var.subnet_ids == null
    error_message = "`vnet_resource_group_name` must not be set when `subnet_ids` is not empty. "
  }
  description = "The name of the resource group holding the VNET. "
}
variable "vnet_name" {
  type = string
  default = null
  validation {
    condition     = var.subnet_ids != null && var.vnet_name == null || var.subnet_ids == null
    error_message = "`vnet_name` must not be set when `subnet_ids` is not empty. "
  }
  description = "The name of the VNET. "
}
variable "subnet_names" {
  type = list(string)
  default = null
  validation {
    condition     = var.subnet_ids != null && var.subnet_names == null || var.subnet_ids == null
    error_message = "`subnet_names` must not be set when `subnet_ids` is not empty. "
  }
  description = "The list of the names of the subnets. "
}

##### CMK Variables #####
variable "cmk_resources" {
  type = object({
    key_vault_id = string
    key_name     = string
    managed_id   = string
  })
  default = null
  description = "CMK resources for CMK encryption. If not provided(default), no CMK encryption will be created. `key_vault_id` is the CMK Key vault ID. `key_name` is the name of the key. `managed_id` is the ID of the user assigned managed identity to be used to access the key. "
}