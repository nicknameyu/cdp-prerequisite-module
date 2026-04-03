# AWS CDP CMK Prerequisites Terraform Module

This Terraform module provisions the AWS Customer Managed Key (CMK) infrastructure required as a prerequisite for deploying [Cloudera Data Platform (CDP)](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-aws-req-kms.html) on AWS. It handles KMS key creation (or adoption of an existing key), optional S3 bucket encryption, and the IAM policy attachments needed by CDP roles to use the key.

---

## Features

- Creates a new AWS KMS Customer Managed Key, or references an existing key by alias
- Creates a KMS alias for the key
- Optionally enables SSE-KMS encryption on a CDP S3 bucket
- Creates and attaches an EC2 KMS IAM policy to the CDP cross-account role
- Creates a KMS read-only IAM policy and attaches it to one or more CDP prerequisite roles

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                   AWS Account                           │
│                                                         │
│  ┌──────────────┐     ┌──────────────────────────────┐  │
│  │  KMS CMK     │────▶│  KMS Alias (alias/<name>)    │  │
│  │  (optional   │     └──────────────────────────────┘  │
│  │   creation)  │                                        │
│  └──────┬───────┘                                        │
│         │                                                │
│         ├──▶ S3 Bucket SSE-KMS (optional)               │
│         │                                                │
│         ├──▶ EC2 KMS Policy ──▶ Cross-Account Role      │
│         │                                                │
│         └──▶ SSE KMS Read-Only Policy ──▶ CDP Roles     │
└─────────────────────────────────────────────────────────┘
```

---

## Usage

### Create a new KMS key and encrypt an S3 bucket

```hcl
module "cdp_cmk" {
  source = "./aws/cmk-prerequisites"

  create_key             = true
  key_alias              = "my-cdp-cmk"
  cross_account_role_arn = "arn:aws:iam::123456789012:role/my-cdp-cross-account-role"
  s3_bucket_id           = "my-cdp-data-bucket"
  ec2_kms_policy_name    = "cdp-ec2-kms-policy"

  cdp_prerequisite_role_names = [
    "my-cdp-idbroker-role",
    "my-cdp-datalake-admin-role",
  ]

  tags = {
    Environment = "production"
    Project     = "cdp"
  }
}
```

### Use an existing KMS key (by alias)

```hcl
module "cdp_cmk" {
  source = "./aws/cmk-prerequisites"

  create_key             = false
  key_alias              = "existing-cdp-cmk"
  cross_account_role_arn = "arn:aws:iam::123456789012:role/my-cdp-cross-account-role"

  cdp_prerequisite_role_names = [
    "my-cdp-idbroker-role",
  ]
}
```

---

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.0    |
| aws       | >= 4.0    |

---

## Providers

| Name | Version |
|------|---------|
| aws  | >= 4.0  |

---

## Variables

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `create_key` | `bool` | `true` | no | When `true`, a new KMS key is created. When `false`, an existing key is looked up by `key_alias`. |
| `key_alias` | `string` | — | **yes** | The KMS key alias (without the `alias/` prefix). Used to name a new key or to look up an existing one. |
| `cross_account_role_arn` | `string` | — | **yes** | ARN of the CDP cross-account IAM role. Granted full KMS permissions in the key policy and attached the EC2 KMS policy. |
| `s3_bucket_id` | `string` | `null` | no | ID of the S3 bucket to configure with SSE-KMS encryption. When `null`, no bucket encryption is configured. |
| `cdp_prerequisite_role_names` | `list(string)` | `[]` | no | List of IAM role names that require KMS `Decrypt` access (e.g. IDBroker, Data Lake Admin roles). |
| `ec2_kms_policy_name` | `string` | `"cdp-ec2-kms-policy"` | no | Name of the IAM policy created for EC2 KMS operations and attached to the cross-account role. |
| `tags` | `map(string)` | `null` | no | Map of tags to apply to all created resources. |

---

## Outputs

| Name | Description |
|------|-------------|
| `kms_key_arn` | ARN of the KMS key (created or existing). |

---

## IAM Policies

This module creates and manages the following IAM policies:

### `aws-cdp-kms-key-policy.json` — KMS Key Resource Policy

Applied directly to the KMS key. Grants full `kms:*` access to:
- The AWS account root
- The CDP cross-account role
- The AWS Auto Scaling service-linked role (`AWSServiceRoleForAutoScaling`)

### `aws-cdp-ec2-kms-policy.json` — EC2 KMS Policy

Attached to the cross-account role. Grants EC2 permissions needed to manage encrypted volumes and snapshots:
- `ec2:CopyImage`, `ec2:CreateSnapshot`, `ec2:DeleteSnapshot`, `ec2:DescribeSnapshots`
- `ec2:CreateVolume`, `ec2:DeleteVolume`, `ec2:DescribeVolumes`, `ec2:DeregisterImage`

### `aws-cdp-sse-kms-read-only-policy.json` — SSE KMS Read-Only Policy

Attached to all roles listed in `cdp_prerequisite_role_names`. Grants `kms:Decrypt` on the CMK, scoped to the key ARN.

### `aws-cdp-sse-kms-read-write-policy.json` — SSE KMS Read-Write Policy

> **Note:** This policy file is included in the `policies/` directory but is not currently applied by the module. It can be used manually or referenced in future module versions. It grants `kms:Decrypt` and `kms:GenerateDataKey` on the CMK.

---

## Notes

- The `cross_account_role_arn` is parsed to extract the role name for policy attachment. It must follow the standard ARN format `arn:aws:iam::<account-id>:role/<role-name>`.
- When `create_key = false`, the module looks up both the key and its alias by the value of `key_alias`. The alias must already exist in the account.
- S3 bucket encryption is only configured when `s3_bucket_id` is provided. The bucket must already exist.
- Tags are applied to the KMS key, KMS alias, and IAM policies where supported.

---

## License

See the repository root for license information.