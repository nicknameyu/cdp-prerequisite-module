
############### Storage Location Base #################
resource "aws_s3_bucket" "cdp" {
  bucket         = var.cdp_bucket_name
  force_destroy  = true
	tags           = var.tags
}

resource "aws_s3_object" "folders" {
  for_each = var.folders
  bucket   = aws_s3_bucket.cdp.id
  key      = "${each.value}/"
  source   = "/dev/null"
}

output "storage_locations" {
  value = [for x in aws_s3_object.folders : "${aws_s3_bucket.cdp.id}/${x.key}" ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count = var.cmk == null ? 0:1
  bucket = aws_s3_bucket.cdp.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id =  var.cmk.create_key ? aws_kms_key.cdp[0].arn : data.aws_kms_key.cdp[0].arn
      sse_algorithm = "aws:kms"
    }
  }
}