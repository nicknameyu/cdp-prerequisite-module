############### KMS Key ##############

resource "aws_kms_key" "cdp" {
	count       = var.cmk == null ? 0 : (var.cmk.create_key ? 1:0)
  description = "KMS key for CDP"
  policy = replace(
    replace(file("${path.module}/policies/aws-cdp-kms-key-policy.json"), "$${AWS_ACCOUNT_ID}", data.aws_caller_identity.current.account_id),
    "$${CDP_CROSS_ACCOUNT_ROLE_ARN}", (var.cross_account_role.create_role ? aws_iam_role.cross_account[0].arn : data.aws_iam_role.cross_account[0].arn))
  tags = var.tags
}
data "aws_kms_key" "cdp" {
	count       = var.cmk == null ? 0 : (var.cmk.create_key ? 0:1)
	key_id      = "alias/${var.cmk.key_alias}" 
}
resource "aws_kms_alias" "cdp" {
  count         = var.cmk == null ? 0 : (var.cmk.create_key ? 1:0)
  name          = "alias/${var.cmk.key_alias}"
  target_key_id = aws_kms_key.cdp[0].key_id
}

data "aws_kms_alias" "cdp" {
  count       = var.cmk == null ? 0 : (var.cmk.create_key ? 0:1)
  name        = "alias/${var.cmk.key_alias}"
}

output "kms_key_arn" {
  value = var.cmk == null ? null : (var.cmk.create_key ? aws_kms_key.cdp[0].arn : data.aws_kms_key.cdp[0].arn)
}
