variable "tags" {
  type = map(string)
  default = null
}
variable "region" {
  type = string
  default = "us-west-2"
}
variable "create_eks_role" {
  type = bool
  default = false
  description = "A flag to control whether to create the EKS role. Default to `false`. Please set it to true when using reduced permission."
}
variable "liftie_role_stack_name" {
  type = string
  default = null
  description = "The name of the CloudFormation stack to create EKS role pair."
  validation {
    condition = ( var.create_eks_role == true && var.liftie_role_stack_name != null ) || var.create_eks_role == false
    error_message = "Variable `liftie_role_stack_name` can't be empty when `create_eks_role` is true "
  }
}

variable "xaccount_role_name" {
  type = string
  description = "CDP cross account role name. This module will attach necessary permission policies to this role."
}
variable "cdp_bucket_name" {
  type = string
  description = "The name of the S3 bucket for CDP environment. Need this name to replace some key words in permission policy."
}

variable "idbroker_role_name" {
  type = string
  description = "This module will use this role name to replace the key workds in permission policy."
}
variable "log_role_name" {
  type = string
  description = "This module will use this role name to replace the key workds in permission policy."
}
variable "kms_key_arn" {
  type = string
  default = ""
  description = "This module will use this key arn to replace the key workds in permission policy."
}
variable "policy_prefix" {
  type = string
  default = "cdp"
  description = "Prefix for the name of some resources."
}

variable "enable_de" {
  type = bool
  default = true
  description = "Enable permissions for Data Engineering."
}
variable "enable_df" {
  type = bool
  default = true
  description = "Enable permissions for Data Flow."
}
variable "enable_ai" {
  type = bool
  default = true
  description = "Enable permissions for AI."
}
variable "enable_dw" {
  type = bool
  default = true
  description = "Enable permissions for Data Warehouse."
}

variable "enable_cmk" {
  type = bool
  default = true
  description = "Enable permissions for CMK on Lifie clusters."
}