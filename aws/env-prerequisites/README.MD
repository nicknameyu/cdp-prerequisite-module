# Terraform Variables for CDP Environment on AWS

This document describes the input variables used in this Terraform module for provisioning **Cloudera Data Platform (CDP)** resources on AWS.

---

## 📍 Overview

The variables define AWS configurations such as region, S3 bucket settings, IAM roles/policies, and SSH key details used to deploy CDP infrastructure components.

---

## ⚙️ Variables

### `region`
- **Type:** `string`  
- **Default:** `"us-west-2"`  
- **Description:** The AWS region to deploy resources.

---

### `tags`
- **Type:** `map(string)`  
- **Default:** `null`  
- **Description:** Optional key-value pairs to tag all created resources.

---

### `cdp_bucket_name`
- **Type:** `string`  
- **Required:** Yes  
- **Description:** The name of the S3 bucket for CDP environment storage.

---

### `folders`
- **Type:**  
  ```hcl
  object({
    data    = string
    logs    = string
    backups = string
  })
  ```
- **Default:**
  ```hcl
  {
    data    = "data"
    logs    = "logs"
    backups = "backups"
  }
  ```
- **Description:** Folder names within the S3 bucket for organizing CDP data, logs, and backups.

---

### `ssh_key_name`
- **Type:** `string`  
- **Default:** `""`  
- **Description:**  
  The name of the SSH key in AWS.  
  If not provided, no SSH key will be created.

---

### `ssh_key`
- **Type:** `string`  
- **Default:** `null`  
- **Description:**  
  The public SSH key used to create and configure SSH access to CDP instances.

---

### `instance_profile_names`
- **Type:**  
  ```hcl
  object({
    data_access = string
    log_access  = string
  })
  ```
- **Default:**
  ```hcl
  {
    data_access = "cdp-data-access-instance-profile"
    log_access  = "cdp-log-access-instance-profile"
  }
  ```
- **Description:** The names of instance profiles used for CDP provisioning.

---

### `role_names`
- **Type:**  
  ```hcl
  object({
    idbroker       = string
    datalake_admin = string
    logger         = string
    ranger         = string
  })
  ```
- **Default:**
  ```hcl
  {
    idbroker       = "cdp-idbroker-role"
    datalake_admin = "cdp-datalake-admin-role"
    logger         = "cdp-logger-role"
    ranger         = "cdp-ranger-role"
  }
  ```
- **Description:** IAM role names required by CDP for access management and logging.

---

### `policy_names`
- **Type:**  
  ```hcl
  object({
    cross_account_policy            = string
    ec2-kms-policy                  = string
    sse-kms-read-only-policy        = string
    sse-kms-read-write-policy       = string
    idbroker-assume-role-policy     = string
    log-policy                      = string
    datalake-restore-policy         = string
    backup-policy                   = string
    ranger-audit-s3-policy          = string
    bucket-access-policy            = string
    datalake-backup-policy          = string
    datalake-admin-s3-policy        = string
  })
  ```
- **Default:**
  ```hcl
  {
    cross_account_policy        = "cdp-cross-account-policy"
    ec2-kms-policy              = "cdp-ec2-kms-policy"
    sse-kms-read-only-policy    = "cdp-sse-kms-read-only-policy"
    sse-kms-read-write-policy   = "cdp-sse-kms-read-write-policy"
    idbroker-assume-role-policy = "cdp-idbroker-assume-role-policy"
    log-policy                  = "cdp-log-policy"
    datalake-restore-policy     = "cdp-datalake-restore-policy"
    backup-policy               = "cdp-backup-policy"
    ranger-audit-s3-policy      = "cdp-ranger-audit-s3-policy"
    bucket-access-policy        = "cdp-bucket-access-policy"
    datalake-backup-policy      = "cdp-datalake-backup-policy"
    datalake-admin-s3-policy    = "cdp-datalake-admin-s3-policy"
  }
  ```
- **Description:** The IAM policy names used in CDP provisioning.

---

## 🚀 Example Usage

```hcl
module "cdp_aws_env" {
  source = "./modules/cdp_aws"

  region           = "us-west-2"
  cdp_bucket_name  = "my-cdp-storage-bucket"
  ssh_key_name     = "my-aws-key"
  ssh_key          = file("~/.ssh/id_rsa.pub")

  tags = {
    Environment = "dev"
    Owner       = "team-cloud"
  }
}
```

---

## 🧩 Notes

- Ensure the **`cdp_bucket_name`** exists or is managed by this module before provisioning dependent resources.  
- If **`ssh_key`** is not provided, Terraform will skip SSH key creation.  
- Default IAM roles and policies follow the Cloudera CDP naming convention but can be customized as needed.
