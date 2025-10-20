# Terraform KMS Key Module

This Terraform module manages the creation and configuration of a KMS key and related IAM policies for CDP deployment.  
It supports both creating a new key or using an existing one, and can optionally integrate with S3 buckets and cross-account roles.

## Variables

### `tags`
- **Type:** `map(string)`  
- **Default:** `null`  
- Key-value pairs to tag the created AWS resources.

### `create_key`
- **Type:** `bool`  
- **Default:** `true`  
- **Description:** Whether to create a new KMS key (`true`) or use an existing key (`false`).

### `key_alias`
- **Type:** `string`  
- **Description:** The alias for the KMS key. This alias will be used for easy reference in AWS.

### `cross_account_role_arn`
- **Type:** `string`  
- **Description:** ARN of the cross-account IAM role that requires access to the KMS key.  
  The KMS key policy will include permissions for this role.

### `s3_bucket_id`
- **Type:** `string`  
- **Default:** `null`  
- **Description:** ID of the S3 bucket (e.g., CDP data bucket) to be encrypted using this KMS key.  
  If not specified, the existing encryption configuration of the bucket remains unchanged.

### `cdp_prerequisite_role_names`
- **Type:** `list(string)`  
- **Default:** `[]`  
- **Description:** List of IAM role names that require access to the KMS key for encryption and decryption operations.

### `ec2_kms_policy_name`
- **Type:** `string`  
- **Default:** `"cdp-ec2-kms-policy"`  
- **Description:** Name of the IAM policy to be created for EC2 instances to use the KMS key.

## Example Usage

```hcl
module "cmk_prerequisites" {
  source = "${path to module}/cmk-prerequisites"

  create_key                 = true
  key_alias                  = "alias/my-cdp-key"
  cross_account_role_arn     = "arn:aws:iam::123456789012:role/CrossAccountRole"
  s3_bucket_id               = "my-cdp-bucket"
  cdp_prerequisite_role_names = ["cdp-datalake-admin-role", "cdp-logger-role"]
  tags = {
    Environment = "dev"
    Project     = "CDP"
  }
}
```