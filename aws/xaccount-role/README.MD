# Cross account role module

Use this module to create cross account role or grant necessary permission policy to an existing cross account role.

## Inputs

The following input variables are configurable for this module:
- `cross_account_role_name`
  - Description: The name of the cross-account IAM role to be created or referenced.
  - Type: string
  - Required: Yes

- `create_role`
  - Description: Controls whether to create the IAM role. If true, a new role is created. If false, the module assumes a role with the name cross_account_role_name already exists.
  - Type: bool
  - Default: true

- `cdp_xaccount_account_id`
  - Description: The Cloudera AWS Account ID that this role will trust. This is used to build the IAM role's trust policy.
  - Type: string
  - Default: null
  - Required: Yes, when create_role is true.

- `cdp_xaccount_external_id`
  - Description: The unique external ID provided by Cloudera. This is used as a condition in the trust policy to prevent the "confused deputy" problem.
  - Type: string
  - Default: null
  - Required: Yes, when create_role is true.

- `cross_account_policy_name`
  - Description: The name for the IAM policy that will be created and attached to the role.
  - Type: string
  - Default: "cdp_cross_account_policy"

- `default_permission`
  - Description: A flag to determine the set of permissions to attach. If true, a default, broader set of permissions is used. If false, a more restrictive, reduced set of permissions is applied.
  - Type: bool
  - Default: false

- `tags`
  - Description: A map of key-value tags to apply to the IAM role and policy resources created by this module.
  - Type: map(string)
  - Default: null

- `aws_sso_user_arn_keyword`
  - Description: A keyword used to establish a trust relationship with an AWS SSO user, allowing them to assume this role for operational tasks (e.g., EKS cluster access). (Note: May be for a future feature)
  - Type: string
  - Default: "dqoYxNKsVt"


## Usage Examples

### Example 1: Create a New Cross-Account Role

This is the most common use case. The module will provision a new IAM role and policy with the specified details for Cloudera integration.

```hcl
module "cdp_cross_account_role" {
  source = "./modules/iam-role" // or your module source

  create_role                = true
  cross_account_role_name    = "CDP-Cross-Account-Access-Role"
  cross_account_policy_name  = "CDP-Cross-Account-Access-Policy"
  cdp_xaccount_account_id    = "123456789012" // Cloudera's AWS Account ID
  cdp_xaccount_external_id   = "your-cloudera-external-id"
  default_permission         = true // Use the broader default permissions

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Service     = "CDP"
  }
}
```

### Example 2: Referencing an Existing Role
If the cross-account role is managed outside of this Terraform configuration, you can use this module to reference it by setting `create_role` to `false`.
```hcl
module "cdp_cross_account_role_reference" {
  source = "./modules/iam-role" // or your module source

  create_role             = false
  cross_account_role_name = "Existing-Manually-Created-Role"

  // cdp_xaccount_account_id and cdp_xaccount_external_id are not needed
  // when create_role is false.
}
```