# data services prerequisites module

When creating CDP EKS based data services, other than the permissions for environment, users also need some other permission policies. This module is to create necessary permission policies and assign them to required resources.

## Resources to be created

- CloudFormation stact to create EKS role pairs for EKS clusters.

## Variable instructions
---

### `tags`
- **Type:** `map(string)`  
- **Default:** `null`  
- **Description:** Optional map of tags to apply to created resources.

---

### `region`
- **Type:** `string`  
- **Default:** `"us-west-2"`  
- **Description:** AWS region where resources will be created.

---

### `create_eks_role`
- **Type:** `bool`  
- **Default:** `false`  
- **Description:**  
  A flag to control whether to create the EKS role.  
  Default is `false`.  
  Set to `true` when using reduced permission.

---

### `liftie_role_stack_name`
- **Type:** `string`  
- **Default:** `null`  
- **Description:**  
  The name of the CloudFormation stack to create the EKS role pair.  
  This variable is required when `create_eks_role` is set to `true`.

  **Validation Rule:**  
  - When `create_eks_role = true`, `liftie_role_stack_name` must not be null.  
  - When `create_eks_role = false`, this value can be null.

---

### `xaccount_role_name`
- **Type:** `string`  
- **Description:**  
  CDP cross-account role name.  
  The module will attach necessary permission policies to this role.

---

### `cdp_bucket_name`
- **Type:** `string`  
- **Description:**  
  The name of the S3 bucket for the CDP environment.  
  Used to replace keywords in permission policies.

---

### `idbroker_role_name`
- **Type:** `string`  
- **Description:**  
  Role name used to replace keywords in permission policies.

---

### `log_role_name`
- **Type:** `string`  
- **Description:**  
  Role name used to replace keywords in permission policies.

---

### `kms_key_arn`
- **Type:** `string`  
- **Default:** `""`  
- **Description:**  
  KMS key ARN used to replace keywords in permission policies.

---

### `policy_prefix`
- **Type:** `string`  
- **Default:** `"cdp"`  
- **Description:**  
  Prefix used for naming resources such as IAM policies.

---

### `enable_de`
- **Type:** `bool`  
- **Default:** `true`  
- **Description:**  
  Enable permissions for **Data Engineering**.

---

### `enable_df`
- **Type:** `bool`  
- **Default:** `true`  
- **Description:**  
  Enable permissions for **Data Flow**.

---

### `enable_ai`
- **Type:** `bool`  
- **Default:** `true`  
- **Description:**  
  Enable permissions for **AI**.

---

### `enable_dw`
- **Type:** `bool`  
- **Default:** `true`  
- **Description:**  
  Enable permissions for **Data Warehouse**.
