######### universal variables #########

variable "tags" {
  description = "Tags to be applied to the resources."
  type = map(string)
  default = null
}

variable "location" {
  description = "Azure region where the resources will be created."
  type = string
  default = "westus"
}

########### mandatory prerequisites #############
variable "create_resource_group" {
  description = "If true, resource group will be created. If false, resource group must be existing."
  type = bool
  default = true
}
variable "resource_group_name" {
  type = string
}
variable "managed_id" {
  description = "The name of the required managed identities."
  type = object({
    assumer    = string
    dataaccess = string
    logger     = string
    ranger     = string
  })
}

variable "obj_storage" {
  type = object({
    storage_account_name   = string
    data_container_name    = string
    logs_container_name    = string
    backups_container_name = string
  })
  description = "The names of the ADLS storage account and containers."
}
variable "obj_storage_performance" {
  type = object({
    account_tier = string
    replication  = string
  })
  default = {
    account_tier = "Standard"
    replication  = "LRS"
  }
}

#### Optional prerequisite ####


variable "cmk" {
  description = "The names of the key vault and the key. If not provided, the key vault won't be created. Customer need configure it correctly."
  type = object({
    kv_name       = string
    key_name      = string
    spn_object_id = string              # SPN Object ID is to grant proper access policy to SPN so that it can access the key in the KV.
  })
  default = null
}

variable "file_storage" {
  description = "The name of the file storage that could be used in Machine Learning. If not provided, the file storage won't be created."
  type = object({
    storage_account_name = string
    file_share_name      = string
    subnet_ids           = list(string)         # a list of subnet IDs that need access to this file storage
  })
  default = null
}
variable "file_storage_performance" {
  description = "The performance of the file storage."
  type = object({
    account_tier = string
    replication  = string
  })
  default = {
    account_tier = "Premium"
    replication  = "LRS"
  }
}
variable "raz_mi_name" {
  description = "RAZ managed identity name."
  type        = string
  default     = null
}
variable "dw_mi" {
  description = "The name of the custom role for data warehouse managed identity. If not provided, the custom role won't be created."
  type = object({
    managed_identiy_name = string
    custom_role_name     = string
  })
  default = null
}