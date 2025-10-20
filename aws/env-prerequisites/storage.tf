
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
output "s3_bucket_id" {
  value = aws_s3_bucket.cdp.arn
}
