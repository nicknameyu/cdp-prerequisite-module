# CDP Cross-Account Role Terraform Module

This Terraform module creates the AWS IAM resources required for [Cloudera Data Platform (CDP)](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-aws-req-credential.html) to manage resources in your AWS account via a cross-account trust relationship.

## Overview

CDP requires a cross-account IAM role in your AWS account so that the Cloudera control plane can provision and manage cloud infrastructure on your behalf. This module:

- Creates an **IAM policy** (either default or reduced permissions) and attaches it to the cross-account role.
- Optionally **creates a new IAM role** with a trust policy scoped to Cloudera's account ID and external ID, or **attaches the policy to an existing role**.

---

## Usage

### Create a new cross-account role (default)

```hcl
module "cdp_xaccount_role" {
  source = "./aws/xaccount-role"

  cross_account_role_name   = "my-cdp-cross-account-role"
  cdp_xaccount_account_id   = "123456789012"   # Cloudera's AWS account ID
  cdp_xaccount_external_id  = "my-external-id" # Provided by CDP during credential setup
}
```

### Attach policy to an existing role

```hcl
module "cdp_xaccount_role" {
  source = "./aws/xaccount-role"

  cross_account_role_name = "my-existing-role"
  create_role             = false
}
```

### Use reduced permissions

```hcl
module "cdp_xaccount_role" {
  source = "./aws/xaccount-role"

  cross_account_role_name   = "my-cdp-cross-account-role"
  cdp_xaccount_account_id   = "123456789012"
  cdp_xaccount_external_id  = "my-external-id"
  default_permission        = false
}
```

---

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.0    |
| aws       | >= 4.0    |

---

## Inputs

| Name                       | Type          | Default          | Required | Description |
|----------------------------|---------------|------------------|----------|-------------|
| `cross_account_role_name`  | `string`      | —                | **Yes**  | The name of the cross-account IAM role to create or look up. |
| `cdp_xaccount_account_id`  | `string`      | `null`           | Conditionally | The Cloudera AWS account ID to be trusted in the role's assume-role policy. Required when `create_role = true`. |
| `cdp_xaccount_external_id` | `string`      | `null`           | Conditionally | The Cloudera external ID for the trust relationship. Required when `create_role = true`. |
| `create_role`              | `bool`        | `true`           | No       | When `true`, creates a new IAM role. When `false`, looks up an existing role by `cross_account_role_name` and attaches the policy to it. |
| `default_permission`       | `bool`        | `false`          | No       | When `true`, uses the broader default permission policy. When `false`, uses the reduced permission policy. See [Permission Policies](#permission-policies) below. |
| `cross_account_policy_name`| `string`      | `"cdp_cross_account_policy"` | No | The name to give the created IAM policy. |
| `aws_sso_user_arn_keyword` | `string`      | `"dqoYxNKsVt"`   | No       | A keyword used to scope the trust relationship to a specific SSO user ARN (e.g., for EKS troubleshooting access). |
| `tags`                     | `map(string)` | `null`           | No       | Tags to apply to all created resources. The policy also receives an automatic `PolicyType` tag (`"default"` or `"reduced"`). |

---

## Outputs

| Name                | Description |
|---------------------|-------------|
| `xaccount_role_arn` | The ARN of the cross-account IAM role (created or looked up). |

---

## Permission Policies

The module selects one of two bundled policy files based on the `default_permission` variable.

### Default Policy (`default_permission = true`)

A broad set of permissions intended for full CDP feature support, including:

| Service | Permissions |
|---------|-------------|
| EC2 | Full (`ec2:*`) |
| EKS | Full (`eks:*`) |
| RDS | Full (`rds:*`) |
| S3 | Scoped CRUD + bucket management |
| IAM | Role & instance-profile management, `PassRole` |
| ELB | Full (`elasticloadbalancing:*`) |
| Auto Scaling | Full (`autoscaling:*`) |
| KMS | Key creation, encryption/decryption, aliasing |
| CloudFormation | Full (`cloudformation:*`) |
| CloudWatch | Alarm management |
| Route 53 | Hosted zone & record management |
| ACM | Certificate lifecycle |
| EFS | Full (`elasticfilesystem:*`) |
| ECR | Read-only (`DescribeRepositories`, `GetAuthorizationToken`) |
| SSM | Read-only on EKS optimized AMI parameters |
| STS | `DecodeAuthorizationMessage` |
| Service Quotas | `ListServiceQuotas` |
| Pricing | `GetProducts` |

### Reduced Policy (`default_permission = false`) *(default)*

A least-privilege policy that scopes destructive actions to resources tagged with `Cloudera-Resource-Name: crn:cdp:*`, minimising the blast radius of the cross-account role. It covers:

- **EC2**: Describe-\* operations, create/run/terminate instances (with tag conditions on destructive actions)
- **IAM**: `PassRole`, scoped instance-profile management for `liftie-*` resources
- **RDS**: Instance and subnet group lifecycle
- **ELB**: Load balancer, target group, and listener management
- **Auto Scaling**: Group create/update/delete
- **CloudFormation**: Stack create/update/describe
- **CloudWatch**: Metric alarms
- **KMS**: `ListKeys`, `ListAliases`
- **S3**: `GetBucketLocation`

> **Note:** Tag-conditioned destructive actions require that CDP-managed resources are tagged with `Cloudera-Resource-Name` containing a value matching `crn:cdp:*`.

---

## Trust Policy

When `create_role = true`, the role's assume-role policy is built from `policies/cdp-cross-account-trust-policy.json` with three placeholders substituted at apply time:

| Placeholder             | Variable                    | Description |
|-------------------------|-----------------------------|-------------|
| `${CLDR_ACCOUNT_ID}`    | `cdp_xaccount_account_id`   | Cloudera's AWS account ID |
| `${CLDR_EXTERNAL_ID}`   | `cdp_xaccount_external_id`  | Cloudera's external ID |
| `${PRINCIPAL_ARN_KEY_WORD}` | `aws_sso_user_arn_keyword` | Optional SSO user ARN keyword for operational access |

Both `cdp_xaccount_account_id` and `cdp_xaccount_external_id` are validated to be non-null when `create_role = true`.

---

## Resources Created

| Resource | Type | Condition |
|----------|------|-----------|
| `aws_iam_policy.cross_account` | IAM Policy | Always |
| `aws_iam_role.cross_account` | IAM Role | `create_role = true` |
| `aws_iam_role_policy_attachment.default` | Policy Attachment | Always |

---

## Notes

- The Cloudera account ID and external ID are obtained from the CDP Management Console under **Environments → Shared Resources → Credentials**.
- If you are attaching the policy to an existing role (`create_role = false`), ensure that role already exists before running `terraform apply`.
- The `aws_sso_user_arn_keyword` variable is reserved for future use and can be left at its default value in most deployments.