
############### IAM ROLES ###################
# KMS policies
# resource "aws_iam_policy" "kms_ro" {
#   name        = "cdp-sse-kms-read-only-policy"
#   path        = "/"
#   description = "cdp-sse-kms-read-only-policy"

#   policy = replace(file("./policies/aws-cdp-sse-kms-read-only-policy.json"), "$${KEY_ARN}", aws_kms_alias.cdp[0].arn)
#   tags = var.tags
# }
resource "aws_iam_policy" "kms_rw" {
  count       = var.cmk == null ? 0:1
  name        = var.policy_names.sse-kms-read-write-policy
  path        = "/"
  description = "cdp-sse-kms-read-write-policy"

  policy      = replace(file("${path.module}/policies/aws-cdp-sse-kms-read-write-policy.json"), "$${KEY_ARN}", var.cmk.create_key ? aws_kms_alias.cdp[0].arn : data.aws_kms_alias.cdp[0].arn)
  tags        = var.tags
}
# IDBROKER role
resource "aws_iam_policy" "assume" {
  name        = var.policy_names.idbroker-assume-role-policy
  path        = "/"
  description = "cdp-idbroker-assume-role-policy"

  policy = file("${path.module}/policies/aws-cdp-idbroker-assume-role-policy.json")
  tags = var.tags
}
resource "aws_iam_policy" "log" {
  name        = var.policy_names.log-policy
  path        = "/"
  description = "cdp-log-policy"

  policy = replace(
    replace(file("${path.module}/policies/aws-cdp-log-policy.json"), "$${LOGS_BUCKET_ARN}", aws_s3_bucket.cdp.arn), 
    "$${LOGS_LOCATION_BASE}", 
    "${aws_s3_bucket.cdp.arn}/${aws_s3_object.folders[var.folders.logs].key}") 
  tags = var.tags
}

resource "aws_iam_role" "idbroker" {
  name                = var.role_names.idbroker
  assume_role_policy  = file("${path.module}/policies/aws-cdp-ec2-role-trust-policy.json")

  tags = var.tags
}


# LOG ROLE
resource "aws_iam_policy" "restore" {
  name        = var.policy_names.datalake-restore-policy
  path        = "/"
  description = "datalake-restore-policy"

  policy      = replace(file("${path.module}/policies/aws-datalake-restore-policy.json"), "$${CDP_BUCKET_ARN}", 
    "${aws_s3_bucket.cdp.arn}") 
  tags = var.tags
}
resource "aws_iam_policy" "cdp_backup" {
  name        = var.policy_names.backup-policy
  path        = "/"
  description = "cdp-backup-policy"

  policy      = replace(file("${path.module}/policies/aws-cdp-backup-policy.json"), "$${BACKUP_LOCATION_BASE}", 
                        "${aws_s3_bucket.cdp.arn}/${aws_s3_object.folders[var.folders.backups].key}") 
  tags        = var.tags
}

resource "aws_iam_role" "log" {
  name                = var.role_names.logger
  assume_role_policy  = file("${path.module}/policies/aws-cdp-ec2-role-trust-policy.json")

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "log" {
  for_each = merge({
                    restore = aws_iam_policy.restore.arn
                    log     = aws_iam_policy.log.arn
                    backup  = aws_iam_policy.cdp_backup.arn
                   },
                   var.cmk == null ? {} : {kms = aws_iam_policy.kms_rw[0].arn}
                   )
  role = aws_iam_role.log.name
  policy_arn = each.value
}
# RANGER_AUDIT_ROLE
resource "aws_iam_policy" "ranger" {
  name        = var.policy_names.ranger-audit-s3-policy
  path        = "/"
  description = "cdp-ranger-audit-s3-policy"

  policy      = replace(file("${path.module}/policies/aws-cdp-ranger-audit-s3-policy.json"), "$${CDP_BUCKET_ARN}", 
                        aws_s3_bucket.cdp.arn) 
  tags        = var.tags
}
resource "aws_iam_policy" "bkt_access" {
  name        = var.policy_names.bucket-access-policy
  path        = "/"
  description = "cdp-bucket-access-policy"

  policy      = replace(file("${path.module}/policies/aws-cdp-bucket-access-policy.json"), "$${CDP_BUCKET_ARN}", 
                      aws_s3_bucket.cdp.arn) 
  tags         = var.tags
}
resource "aws_iam_policy" "dl_backup" {
  name        = var.policy_names.datalake-backup-policy
  path        = "/"
  description = "cdp-datalake-backup-policy"

  policy      = replace(file("${path.module}/policies/aws-datalake-backup-policy.json"), "$${BACKUP_LOCATION_BASE}", 
                         "${aws_s3_bucket.cdp.arn}/${aws_s3_object.folders[var.folders.backups].key}") 
  tags        = var.tags
}

resource "aws_iam_role" "ranger" {
  name                = var.role_names.ranger
  assume_role_policy  = replace(file("${path.module}/policies/aws-cdp-idbroker-role-trust-policy.json"), "$${IDBROKER_ROLE_ARN}", aws_iam_role.idbroker.arn)

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "ranger" {
  for_each = merge({
                    restore    = aws_iam_policy.restore.arn 
                    ranger     = aws_iam_policy.ranger.arn
                    bkt_access = aws_iam_policy.ranger.arn
                    dl_backup  = aws_iam_policy.dl_backup.arn

                   },
                    var.cmk == null ? {} : {kms = aws_iam_policy.kms_rw[0].arn}
                  )

  role       = aws_iam_role.ranger.name
  policy_arn = each.value
}
# DATALAKE_ADMIN_ROLE
resource "aws_iam_policy" "dl_admin" {
  name        = var.policy_names.datalake-admin-s3-policy
  path        = "/"
  description = "cdp-datalake-admin-s3-policy"

  policy      = replace(file("${path.module}/policies/aws-cdp-datalake-admin-s3-policy.json"), "$${STORAGE_LOCATION_BASE}", 
                        "${aws_s3_bucket.cdp.arn}/${aws_s3_object.folders[var.folders.data].key}") 
  tags        = var.tags
}
resource "aws_iam_role" "dl_admin" {
  name                = var.role_names.datalake_admin
  assume_role_policy  = replace(file("${path.module}/policies/aws-cdp-idbroker-role-trust-policy.json"), "$${IDBROKER_ROLE_ARN}", aws_iam_role.idbroker.arn)

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "dl_admin" {
  for_each = merge({
                        dl_admin   = aws_iam_policy.dl_admin.arn,
                        bkt_access = aws_iam_policy.bkt_access.arn,
                        dl_backup  = aws_iam_policy.dl_backup.arn,
                        restore    = aws_iam_policy.restore.arn
                   }, 
                   var.cmk == null ? {} : {kms = aws_iam_policy.kms_rw[0].arn}
                  )
  role = aws_iam_role.dl_admin.name
  policy_arn = each.value
}

output "roles" {
  value = [
      aws_iam_role.idbroker.name,
      aws_iam_role.log.name,
      aws_iam_role.dl_admin.name,
      aws_iam_role.ranger.name
    ]
}

############# Instance Profiles #############
resource "aws_iam_instance_profile" "data_access" {
  name = var.instance_profile_names.data_access
  role = aws_iam_role.idbroker.name
  tags = var.tags
}

resource "aws_iam_instance_profile" "log_access" {
  name = var.instance_profile_names.log_access
  role = aws_iam_role.log.name
  tags = var.tags
}
output "instance_profiles" {
  value = [aws_iam_instance_profile.data_access.name, aws_iam_instance_profile.log_access.name]
}