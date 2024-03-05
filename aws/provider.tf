provider "aws" {
  # Configuration options
  region = var.region
}

data "aws_caller_identity" "current" {}