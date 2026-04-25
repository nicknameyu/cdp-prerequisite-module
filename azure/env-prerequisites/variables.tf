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

### CDP Storage ###
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

### Additional MIs ###
variable "raz_mi_name" {
  description = "RAZ managed identity name."
  type        = string
  default     = null
}
variable "cmk_ds_mi_name" {
  description = "Managed identity name for CMK, AKS admin."
  type        = string
  default     = null
}

variable "enable_ai" {
/*
This is introduced in Feb 2026
If you are using Cloudera AI, you must also assign the following roles to the Logger managed identity for the data lake storage account:
Storage Account Contributor
Storage Blob Data Contributor for the container: [data], prefix: [modelregistry] (for example: /modelregistry).
For more information about permissions for Cloudera AI on Azure, see Cloudera AI minimum permissions.
*/
  type        = bool
  default     = true
  description = "Enable CAI permission setting. "
}

### NFS Storage for CAI and CDE ###
variable "create_nfs" {
  default     = false
  type        = bool
  description = "Control whether to create NFS for CDE or CAI. Default to false. "
}
variable "nfs_storage_account_name" {
  type        = string
  default     = null
  description = "The storage account name for the NFS storage"
  validation {
    condition = (var.create_nfs && var.nfs_storage_account_name != null) || ! var.create_nfs
    error_message = "nfs_storage_account_name cannot be null when var.create_nfs is true. "
  }
}
variable "nfs_file_share_name" {
  type    = string
  default = "cml-nfs"
  description = "Name of the file share. "
  validation {
    condition = (var.enable_ai && var.nfs_file_share_name != null) || ! var.enable_ai
    error_message = "nfs_file_share_name cannot be null when var.enable_ai is true. "
  }
}
variable "nfs_storage_performance" {
  type = object({
    account_tier = string
    replication  = string
  })
  default = {
    account_tier = "Premium"
    replication = "LRS"
  }
  description = "Performance parameter for NFS storage account."
}
variable "nfs_size" {
  type = number
  description = "Size of the file share in GB. "
  default = 100
}
### Network firewall controll for sotrage ###
### Including both Environment storage and NFS storage for AI and DE ###
variable "subnet_ids" {
  type = list(string)
  default = []
  description = "Get the list of subnet IDs need to be added to the list to access the storage account. If empty, open access to every network."
}
variable "storage_ip_rules" {
  type = list(string)
  default = []
  description = "Get the list of ip addresses to be added to the list to access the storage account."
}

variable "enable_de" {
/*
This is introduced in Mar 2026. CDE new release requires a couple of new managed identities to handle CDE service and CDE virtual cluster.
Dedicated Managed Identities are required. You must create and use two unique Managed Identities for each Cloudera Data Engineering service. 
Do not share these two identities with another Cloudera Data Engineering service or any other data service.
*/
  type        = bool
  default     = false
  description = "Enable CDE permission setting. When set to true, MIs are created per configuration in `de_mi_names`. "
}
variable "de_mi_names" {
  type        = map(object({
                      service = string
                      cluster = string
                    }))
  default     = null
  description = "Names for the managed identities serving for Data Engineer. There could be multiple DE services on each environment, and each DE service requires a pair of managed identities.When `var.enable_de` is set to true, this variable can't be null. "
  validation {
    condition     = !var.enable_de || var.de_mi_names != null
    error_message = "de_mi_names cannot be null when enable_de is true."
  }
}