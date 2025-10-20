resource "aws_cloudformation_stack" "liftie" {
  # In some circumstances, this role pair may already have been created. 
  count         = var.create_eks_role ? 1:0
  name          = var.liftie_role_stack_name == null ? "cdp-liftie-role-pair" : var.liftie_role_stack_name
  capabilities  = ["CAPABILITY_NAMED_IAM"]
  template_body = file("${path.module}/cloud-formation-stack/aws-liftie-role-pair.yaml")
  parameters    = {
    TelemetryLoggingBucket  = var.cdp_bucket_name
    TelemetryLoggingRootDir = "cluster-logs"
    TelemetryLoggingEnabled = "true"
  }
  tags          = var.tags
}
