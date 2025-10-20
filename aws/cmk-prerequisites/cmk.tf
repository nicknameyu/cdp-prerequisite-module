############### KMS Key ##############
data "aws_caller_identity" "current" {}
resource "aws_kms_key" "cdp" {
	count       = var.create_key ? 1:0
  description = "KMS key for CDP"
  policy = replace(
                   replace(file("${path.module}/policies/aws-cdp-kms-key-policy.json"), "$${AWS_ACCOUNT_ID}", data.aws_caller_identity.current.account_id),
                   "$${CDP_CROSS_ACCOUNT_ROLE_ARN}", var.cross_account_role_arn
                   )
  tags = var.tags
}
data "aws_kms_key" "cdp" {
	count       = var.create_key ? 0:1
	key_id      = "alias/${var.key_alias}" 
}

resource "aws_kms_alias" "cdp" {
  count         = var.create_key ? 1:0
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.cdp[0].key_id
}

data "aws_kms_alias" "cdp" {
  count       = var.create_key ? 0:1
  name        = "alias/${var.key_alias}"
}

output "kms_key_arn" {
  value = var.create_key ? aws_kms_key.cdp[0].arn : data.aws_kms_key.cdp[0].arn
}


## S3 bucket encryption.
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count = var.s3_bucket_id == null ? 1:0
  bucket = var.s3_bucket_id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id =  var.create_key ? aws_kms_key.cdp[0].arn : data.aws_kms_key.cdp[0].arn
      sse_algorithm = "aws:kms"
    }
  }
}

## Cross account role KMS policy assignment.
resource "aws_iam_policy" "ec2kms" {
  name        = var.ec2_kms_policy_name
  path        = "/"
  description = "CDP EC2 KMS Policy"
  policy      = file("${path.module}/policies/aws-cdp-ec2-kms-policy.json")
  tags        = var.tags
}


locals {
  cross_account_role_name = element(split("/", var.cross_account_role_arn), 1)
}
resource "aws_iam_role_policy_attachment" "ec2kms" {
  role       = local.cross_account_role_name
  policy_arn = aws_iam_policy.ec2kms.arn
}

## Resource role KMS policy assignment
resource "aws_iam_policy" "kms_ro" {
  name        = "aws-cdp-sse-kms-read-only-policy"
  path        = "/"
  description = "aws-cdp-sse-kms-read-only-policy"

  policy = replace(file("${path.module}/policies/aws-cdp-sse-kms-read-only-policy.json"), "$${KEY_ARN}", var.create_key? aws_kms_alias.cdp[0].arn : data.aws_kms_alias.cdp[0].arn)
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "cdp_roles" {
  for_each   = toset(var.cdp_prerequisite_role_names)
  role       = each.key
  policy_arn = aws_iam_policy.kms_ro.arn
}