
variable "region" {
  type = string
  default = "us-west-2"
}
variable "cdp_bucket_name" {
  type = string
}
variable "folders" {
  description = "The names of the folders in S3 buckets. Default to data, logs, and backups. "
  type = object({
    data    = string
    logs    = string
    backups = string
  })
  default = {
    data    = "data"
    logs    = "logs"
    backups = "backups"
  }
}

variable "ssh_key" {
  description = "The public key will be used to create an SSH public key in the AWS account. If not provided, the ssh key will not be created."
  type = object({
    name = string
    key  = string
  })
  default = null
}

variable "cross_account_role" {
  type = object({
    name        = string
    create_role = bool
  })
  description = "The name of the cross account role and whether it is an existing role or need to be created."
}

variable "aws_sso_user_arn_keyword" {
  description = "This keyword is used to create trust relationship between the cross account role and the target user, so that the user can assume this role for operation activities, eg. log in the EKS cluster for troubleshooting. "
  type = string
  default = "dqoYxNKsVt"
}

variable "cmk" {
  type    = object({
    key_alias  = string
    create_key = bool
  })
  default = null
  description = "Whether to use KMS in the provisioning. If null, no CMK will be used. If create_key is true, a key will be created, and proper key policy will be attached to the key_alias. If create_key is false, proper key policy will be attached to the key with the key_alias."
}
variable "use_raz" {
  default = null 
  description = "Not yet supported"
}
variable "tags" {
  type    = map(string)
  default = null 
}


variable "role_names" {
  description = "the names of the roles to be used in CDP provisioning."
  type = object({
    idbroker       = string
    logger         = string
    ranger         = string
    datalake_admin = string
  })
  default = {
    idbroker       = "CDP_IDBROKER"
    logger         = "CDP_LOG_ROLE"
    ranger         = "CDP_RANGER_AUDIT"
    datalake_admin = "CDP_DATALAKE_ADMIN"
  }
}

variable "policy_names" {
  description = "The names of the policies to be used in CDP provisioning"
  type = object({
    cross_account_policy            = string
    ec2-kms-policy                  = string
    sse-kms-read-only-policy        = string
    sse-kms-read-write-policy       = string
    idbroker-assume-role-policy     = string
    log-policy                      = string
    datalake-restore-policy         = string
    backup-policy                   = string
    ranger-audit-s3-policy          = string
    bucket-access-policy            = string
    datalake-backup-policy          = string
    datalake-admin-s3-policy        = string
  })
  default = {
    cross_account_policy        = "cdp-cross-account-policy"
    ec2-kms-policy              = "cdp-ec2-kms-policy"
    sse-kms-read-only-policy    = "cdp-sse-kms-read-only-policy"
    sse-kms-read-write-policy   = "cdp-sse-kms-read-write-policy"
    idbroker-assume-role-policy = "cdp-idbroker-assume-role-policy"
    log-policy                  = "cdp-log-policy"
    datalake-restore-policy     = "cdp-datalake-restore-policy"
    backup-policy               = "cdp-backup-policy"
    ranger-audit-s3-policy      = "cdp-ranger-audit-s3-policy"
    bucket-access-policy        = "cdp-bucket-access-policy"
    datalake-backup-policy      = "cdp-datalake-backup-policy"
    datalake-admin-s3-policy    = "cdp-datalake-admin-s3-policy"
  }
}

variable "instance_profile_names" {
  description = "The name of the instance profiles to be used in CDP provisioning."
  type = object({
    data_access = string
    log_access  = string
  })
  default = {
    data_access = "cdp-data-access-instance-profile"
    log_access  = "cdp-log-access-instance-profile"
  }
}