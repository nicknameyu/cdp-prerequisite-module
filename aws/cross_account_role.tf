############### Cross account role #############
resource "aws_iam_policy" "cross_account" {
  count       = var.cross_account_role.create_role ? 1:0
  name        = var.policy_names.cross_account_policy
  path        = "/"
  description = "CDP Cross Account Role policy"
  policy      = file("${path.module}/policies/cdp-cross-account-policy.json")
  tags        = var.tags
}
resource "aws_iam_policy" "ec2kms" {
  count       = var.cross_account_role.create_role ? 1:0
  name        = var.policy_names.ec2-kms-policy
  path        = "/"
  description = "CDP EC2 KMS Policy"
  policy      = file("${path.module}/policies/aws-cdp-ec2-kms-policy.json")
  tags        = var.tags
}

resource "aws_iam_role" "cross_account" {
  count               = var.cross_account_role.create_role ? 1:0
  name                = var.cross_account_role.name
  assume_role_policy  = replace(file("${path.module}/policies/cdp-cross-account-trust-policy.json"), "$${PRINCIPAL_ARN_KEY_WORD}", var.aws_sso_user_arn_keyword)
  managed_policy_arns = [
    aws_iam_policy.cross_account[0].arn,
    aws_iam_policy.ec2kms[0].arn
  ]
  tags = var.tags
}

data "aws_iam_role" "cross_account" {
  count = var.cross_account_role.create_role ? 0:1
  name = var.cross_account_role.name
}
