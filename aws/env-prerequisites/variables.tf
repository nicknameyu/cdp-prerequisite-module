variable "region" {
  type = string
  default = "us-west-2"
}
variable "tags" {
  type = map(string)
  default = null
}
variable "cdp_bucket_name" {
  type = string
  description = "The name of the S3 bucket for CDP environment storage."
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
variable "ssh_key_name" {
  type = string
  default = ""
  description = "The public key will be used to create an SSH public key in the AWS account. If not provided, the ssh key will not be created."
}
variable "ssh_key" {
  description = "The public key will be used to create an SSH public key in the AWS account. This SSH key will be used to configure SSH access to CDP instances."
  type = string
  default = null
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
variable "role_names" {
  type = object({
    idbroker       = string
    datalake_admin = string
    logger         = string
    ranger         = string
  })
  default = {
    idbroker       = "cdp-idbroker-role"
    datalake_admin = "cdp-datalake-admin-role"
    logger         = "cdp-logger-role"
    ranger         = "cdp-ranger-role"
  }
  description = "Names of the required CDP roles."
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