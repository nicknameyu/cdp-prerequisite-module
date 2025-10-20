variable "tags" {
  type = map(string)
  default = null
}
variable "create_key" {
  type = bool
  default = true
  description = "Whether to create a new key or use an existing key."
}

variable "key_alias" {
  type = string
  description = "KMS Key alias."
}

variable "cross_account_role_arn" {
  type = string
  description = "Cross account role arn. KMS key need this value to grant access permission to the cross account role."
}

variable "s3_bucket_id" {
  type = string
  default = null
  description = "S3 bucket ID for CDP S3 bucket to be encrypted with the KMS key. When not provided, bucket will be remain current encryption. "
}

variable "cdp_prerequisite_role_names" {
  type = list(string)
  description = "List of the name of the roles need access to the KMS key for encryption and decryption. "
  default = [  ]
}

variable "ec2_kms_policy_name" {
  type = string
  default = "cdp-ec2-kms-policy"
  description = "Name of the policy for EC2 KMS."
}