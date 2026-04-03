# CDP Data Services Prerequisites – Terraform Module

This Terraform module provisions the AWS IAM policies required for [Cloudera Data Platform (CDP)](https://www.cloudera.com/products/cloudera-data-platform.html) data service operations using **reduced/restricted permissions**. It attaches scoped-down IAM policies to an existing CDP cross-account role and, optionally, creates the EKS role pair needed by the Liftie cluster manager via AWS CloudFormation.

---

## Features

- Creates and attaches reduced-permission IAM policies for each CDP data service to the cross-account role
- Supports selective enablement of individual data services (DE, DF, DW, AI/ML)
- Optionally provisions the EKS master role (`cdp-eks-master-role`) and node instance profile (`cdp-liftie-instance-profile`) via a CloudFormation stack
- Supports Customer-Managed Key (CMK) permissions for Liftie-managed EKS clusters
- All resources are taggable

---

## Usage

```hcl
module "cdp_data_services_prerequisites" {
  source = "./aws/data-services-prerequisites"

  xaccount_role_name = "my-cdp-xaccount-role"
  idbroker_role_name = "my-cdp-idbroker-role"
  log_role_name      = "my-cdp-log-role"
  cdp_bucket_name    = "my-cdp-s3-bucket"

  # Optional: create the EKS role pair via CloudFormation
  create_eks_role        = true
  liftie_role_stack_name = "cdp-liftie-role-pair"

  # Optional: enable CMK support for Liftie clusters
  enable_cmk  = true
  kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/your-key-id"

  tags = {
    Environment = "production"
    Team        = "data-platform"
  }
}
```

---

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.0    |
| aws       | >= 4.0    |

### AWS Provider

This module uses the default AWS provider. Ensure your provider is configured for the correct account and region before applying.

```hcl
provider "aws" {
  region = "us-west-2"
}
```

---

## Resources Created

| Resource | Type | Description |
|---|---|---|
| `aws_iam_policy.reduced` | `aws_iam_policy` | One or more scoped-down IAM policies per enabled data service |
| `aws_iam_role_policy_attachment.reduced_policies` | `aws_iam_role_policy_attachment` | Attaches all created policies to the cross-account role |
| `aws_cloudformation_stack.liftie` | `aws_cloudformation_stack` | *(Optional)* Creates EKS master role and node instance profile for Liftie |

### IAM Policies Created (by service)

| Service Flag | Policy Name(s) | Description |
|---|---|---|
| `enable_ai = true` | `{prefix}-ml-reduced-policy`, `{prefix}-ml-backup-policy`, `{prefix}-ml-restore-policy` | Cloudera Machine Learning (CML) permissions including backup/restore |
| `enable_de = true` | `{prefix}-de-reduced-policy-1` | Cloudera Data Engineering (CDE) reduced permissions |
| `enable_df = true` | `{prefix}-df-reduced-policy` | Cloudera DataFlow (CDF) reduced permissions |
| `enable_dw = true` | `{prefix}-dw-reduced-policy` | Cloudera Data Warehouse (CDW) reduced permissions |
| `enable_cmk = true` | `{prefix}-liftie-cmk-reduced-policy` | CMK (KMS) permissions for Liftie-managed EKS clusters |
| Liftie (auto) | `{prefix}-liftie-reduced-policy1`, `{prefix}-liftie-reduced-policy2` | Core Liftie permissions; enabled automatically when DE, DF, or AI is enabled |

> **Note:** Liftie policies are always created when any of `enable_ai`, `enable_de`, or `enable_df` is `true`, since those services rely on Liftie-managed EKS clusters.

### CloudFormation Stack (optional)

When `create_eks_role = true`, the module deploys a CloudFormation stack that creates:

- **`cdp-eks-master-role`** – EKS service role with `AmazonEKSServicePolicy` and `AmazonEKSClusterPolicy`
- **`cdp-liftie-instance-profile`** – EC2 node instance role and instance profile with policies for:
  - EKS worker node operation
  - Cluster autoscaler
  - EBS and EFS CSI drivers
  - Calico CNI
  - CloudWatch metrics
  - SSM parameter access
  - Telemetry logging to S3 (and optionally KMS decryption)

---

## Variables

| Name | Type | Default | Required | Description |
|---|---|---|---|---|
| `xaccount_role_name` | `string` | — | **Yes** | Name of the existing CDP cross-account IAM role. Policies will be attached to this role. |
| `idbroker_role_name` | `string` | — | **Yes** | Name of the existing CDP IDBroker IAM role. Used as a placeholder in policy documents. |
| `log_role_name` | `string` | — | **Yes** | Name of the existing CDP log IAM role. Used as a placeholder in policy documents. |
| `cdp_bucket_name` | `string` | — | **Yes** | Name of the S3 bucket used for the CDP environment. Referenced in DW and telemetry policies. |
| `region` | `string` | `"us-west-2"` | No | AWS region. Used as a placeholder in Liftie policy documents. |
| `policy_prefix` | `string` | `"cdp"` | No | Prefix applied to the names of all IAM policies created by this module. |
| `tags` | `map(string)` | `null` | No | Tags to apply to all created resources. |
| `enable_de` | `bool` | `true` | No | Enable IAM permissions for Cloudera Data Engineering. |
| `enable_df` | `bool` | `true` | No | Enable IAM permissions for Cloudera DataFlow. |
| `enable_dw` | `bool` | `true` | No | Enable IAM permissions for Cloudera Data Warehouse. |
| `enable_ai` | `bool` | `true` | No | Enable IAM permissions for Cloudera Machine Learning / AI. |
| `enable_cmk` | `bool` | `true` | No | Enable CMK (KMS) permissions for Liftie-managed EKS clusters. |
| `kms_key_arn` | `string` | `""` | No | ARN of the KMS Customer-Managed Key. Required when `enable_cmk = true`. |
| `create_eks_role` | `bool` | `false` | No | Whether to create the EKS role pair (Liftie) via CloudFormation. Set to `true` when using reduced permissions and the roles do not already exist. |
| `liftie_role_stack_name` | `string` | `null` | No | Name for the CloudFormation stack. **Required** when `create_eks_role = true`. |

---

## Notes

- **Pre-existing roles:** This module does not create the cross-account, IDBroker, or log roles. Those must already exist. It only creates and attaches the reduced-permission policies.
- **EKS role pair:** If the `cdp-eks-master-role` and `cdp-liftie-instance-profile` already exist in your account (e.g., created by a previous CDP deployment), leave `create_eks_role = false` to avoid conflicts.
- **Liftie policy activation:** The Liftie base policies (`liftie-reduced-policy1/2`) are automatically included whenever `enable_ai`, `enable_de`, or `enable_df` is `true`. They cannot be independently toggled.
- **ML backup/restore policies:** The CML backup and restore policies are fetched at plan/apply time from Cloudera's public documentation URLs. Ensure outbound HTTPS access is available from your Terraform execution environment.

---

## License

See the repository root for license information.