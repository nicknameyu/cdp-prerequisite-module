variable "tags" {
  type = map(string)
  default = null
}

variable "aws_sso_user_arn_keyword" {
  # This may not be required. But leave it here for future update.
  description = "This keyword is used to create trust relationship between the cross account role and the target user, so that the user can assume this role for operation activities, eg. log in the EKS cluster for troubleshooting. "
  type = string
  default = "dqoYxNKsVt"
}

variable "cross_account_role_name" {
  description = "The name of the cross account role."
  type = string
}
variable "create_role" {
  type = bool
  default = true
  description = "Whether to create cross account role. When true, a new role will be created, otherwise, an existing role with the name `cross_account_policy_name` must exist."
}
variable "default_permission" {
  type = bool
  default = false
  description = "Whether default permission or reduced permission to be used for this cross account role."
}
variable "cross_account_policy_name" {
  type = string
  default = "cdp_cross_account_policy"
  description = "The name of the cross account policy"
}

variable "cdp_xaccount_account_id" {
  type = string
  default = null
  description = "The Cloudera account ID that this cross account role must trust. If not provided, `create_role` must be false. " 
  validation {
    condition = (var.create_role && var.cdp_xaccount_account_id != null) || !var.create_role
    error_message = "`cdp_xaccount_account_id` must be provided when create_role is true."
  }
}
variable "cdp_xaccount_external_id" {
  type = string
  default = null
  description = "The Cloudera account external ID that this cross account role must trust. If not provided, `create_role` must be false. " 
  validation {
    condition = (var.create_role && var.cdp_xaccount_external_id != null) || !var.create_role
    error_message = "`cdp_xaccount_external_id` must be provided when create_role is true."
  }
}