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
variable "subscription_id" {
  type = string
  description = "Azure subscriptino ID to be used to deploy the resources."
}
variable "create_resource_group" {
  description = "If true, resource group will be created. If false, resource group must be existing."
  type = bool
  default = true
}
variable "resource_group_name" {
  type = string
  description = "Name of the CDP resource group."
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
variable "storage_account_name" {
  type = string
  description = "Name of CDP Storage Account"
}
variable "storage_locations" {
  type = object({
    data    = string
    logs    = string
    backups = string
  })
  description = "The names of the storage containers."
  default = {
    data    = "data"
    logs    = "logs"
    backups = "backups"
  }
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

variable "raz_mi_name" {
  description = "RAZ managed identity name."
  type        = string
  default     = null
}
