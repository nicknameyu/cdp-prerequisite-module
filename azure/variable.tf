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


