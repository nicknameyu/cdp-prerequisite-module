############### Cross account role #############
resource "aws_iam_policy" "cross_account" {
  name        = var.cross_account_policy_name
  path        = "/"
  description = "CDP Cross Account Role policy"
  policy      = var.default_permission ? file("${path.module}/policies/cdp-cross-account-policy.json") : file("${path.module}/policies/cdp-cross-account-reduced-policy.json")
  tags        = merge(
                      var.tags,
                      {PolicyType = var.default_permission ? "default":"reduced"}
                    )
}

resource "aws_iam_role" "cross_account" {
  count               = var.create_role ? 1:0
  name                = var.cross_account_role_name
  assume_role_policy  = replace(
                                replace(
                                        replace(file("${path.module}/policies/cdp-cross-account-trust-policy.json"), "$${PRINCIPAL_ARN_KEY_WORD}", var.aws_sso_user_arn_keyword),
                                        "$${CLDR_ACCOUNT_ID}", var.cdp_xaccount_account_id),
                                "$${CLDR_EXTERNAL_ID}", var.cdp_xaccount_external_id)
  tags = var.tags
}

data "aws_iam_role" "cross_account" {
  count = var.create_role ? 0:1
  name  = var.cross_account_role_name
}
resource "aws_iam_role_policy_attachment" "default" {
  role = var.create_role ? aws_iam_role.cross_account[0].name : var.cross_account_role_name
  policy_arn = aws_iam_policy.cross_account.arn
}

output "xaccount_role_arn" {
  value = var.create_role ? aws_iam_role.cross_account[0].arn : data.aws_iam_role.cross_account[0].arn
}