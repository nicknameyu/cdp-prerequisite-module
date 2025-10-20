data "aws_caller_identity" "current" {}

locals {
  liftie_policy_raw = file("${path.module}/policies/aws-ds-restricted-policy-1.json")
  liftie_policy_1   = replace(local.liftie_policy_raw, "$${YOUR-ACCOUNT-ID}", data.aws_caller_identity.current.account_id)
  liftie_policy_2   = replace(local.liftie_policy_1, "$${YOUR-IAM-ROLE-NAME}", var.xaccount_role_name)
  liftie_policy_3   = replace(local.liftie_policy_2, "$${YOUR-IDBROKER-ROLE-NAME}", var.idbroker_role_name)
  liftie_policy_4   = replace(local.liftie_policy_3, "$${YOUR-LOG-ROLE-NAME}", var.log_role_name)
  liftie_policy_5   = replace(local.liftie_policy_4, "$${YOUR-KMS-CUSTOMER-MANAGED-KEY-ARN}", var.kms_key_arn)
  liftie_min_policy = replace(local.liftie_policy_5, "$${YOUR-SUBNET-REGION}", var.region)
  
  # DE policy cannot be put into one policy file. Using two policy file for DE permissions.
  de_policies       = {
    de1       = {
      name         = "${var.policy_prefix}-de-reduced-policy-1"
      description  = "${upper(var.policy_prefix)} reduced policy for Data Engineering part 1"
      policy       = file("${path.module}/policies/aws-de-restricted-policy-part1.json")
    }
    de2       = {
      name         = "${var.policy_prefix}-de-reduced-policy-2"
      description  = "${upper(var.policy_prefix)} reduced policy for Data Engineering part 2"
      policy       = file("${path.module}/policies/aws-de-restricted-policy-part2.json")
    }
  }

  liftie_policies = {
     # Liftie policy cannot be put into one policy file. Using two policy file for Liftie permissions.
    liftie1 = {
      name         = "${var.policy_prefix}-liftie-reduced-policy1"
      description  = "${upper(var.policy_prefix)} reduced policy for Liftie1"
      policy       = local.liftie_min_policy
    }
    liftie2 = {
      name         = "${var.policy_prefix}-liftie-reduced-policy2"
      description  = "${upper(var.policy_prefix)} reduced policy for Liftie2"
      policy       = replace(file("${path.module}/policies/aws-ds-restricted-policy-2.json"), "$${YOUR-ACCOUNT-ID}", data.aws_caller_identity.current.account_id)
    }
  }
  liftie_cmk_policies = {
    liftie_cmk = {
      name         = "${var.policy_prefix}-liftie-cmk-reduced-policy"
      description  = "${upper(var.policy_prefix)} reduced policy for Liftie with CMK"
      policy       = replace(replace(file("${path.module}/policies/aws-liftie-cmk-reduced-policy.json"),
                               "$${YOUR-ACCOUNT-ID}", data.aws_caller_identity.current.account_id),
                        "$${CDP-CROSSACCOUNT-ROLE}", var.xaccount_role_name)
    }
  }
  dw_policy  = {
    dw         = {
      name        = "${var.policy_prefix}-dw-reduced-policy"
      description = "${upper(var.policy_prefix)} reduced policy for Data Warehouse"
      policy      = replace(replace(file("${path.module}/policies/aws-dw-reduced-permissions.json"),
                               "$${ACCOUNT_ID}", data.aws_caller_identity.current.account_id),
                        "$${DATALAKE_BUCKET}", var.cdp_bucket_name)
    }
  }
  df_policy = {
    df         = {
      name        = "${var.policy_prefix}-df-reduced-policy"
      description = "${upper(var.policy_prefix)} reduced policy for Data Flow"
      policy      = replace(
                            replace(file("${path.module}/policies/aws-df-reduced-policy.json"), 
                                    "$${YOUR-ACCOUNT-ID}", 
                                    data.aws_caller_identity.current.account_id ), 
                            "$${YOUR-IDBROKER-ROLE-NAME}", var.idbroker_role_name)
    }
  }
  ml_policy = {
    ml            = {
      name        = "${var.policy_prefix}-ml-reduced-policy"
      description = "${upper(var.policy_prefix)} reduced policy for Machine Learning"
      policy      = replace(replace(file("${path.module}/policies/aws-ml-restricted-policy.json"),
                                  "$${YOUR-ACCOUNT-ID}", data.aws_caller_identity.current.account_id),
                            "$${YOUR-IAM-ROLE-NAME}",
                            var.xaccount_role_name)
    }
  }
  enable_liftie = var.enable_ai || var.enable_de || var.enable_df   # liftie is required for CAI, CDE, CDF.
  reduced_policies  = merge(var.enable_dw ? local.dw_policy:{}, 
                            merge(local.enable_liftie ? local.liftie_policies:{},
                                   merge( var.enable_de ? local.de_policies : {},
                                          merge( var.enable_ai ? local.ml_policy:{},
                                                 merge(var.enable_df ? local.df_policy : {}, 
                                                       var.enable_cmk ? local.liftie_cmk_policies : {}
                                                       )
                                               )
                                        )
                                 )
                           )
}

resource "aws_iam_policy" "reduced" {
  for_each    = local.reduced_policies
  name        = each.value.name
  path        = "/"
  description = each.value.description
  policy      = each.value.policy
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "reduced_policies" {
  for_each   = aws_iam_policy.reduced
  role       = var.xaccount_role_name
  policy_arn = each.value.arn
}
