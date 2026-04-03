# CDP AWS Environment Prerequisites Terraform Module

This Terraform module provisions all AWS prerequisites required for a [Cloudera Data Platform (CDP)](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-idbroker-minimum-setup.html) environment deployment on AWS. It creates the necessary S3 storage, IAM roles, IAM policies, instance profiles, and optionally an SSH key pair.

---

## Resources Created

### S3 Storage (`storage.tf`)
- An S3 bucket for CDP environment storage, with the following sub-folders:
  - `data/` — storage location base for the Datalake
  - `logs/` — log storage location
  - `backups/` — backup storage location

### IAM Roles (`roles.tf`)
| Role | Trust Policy | Description |
|------|-------------|-------------|
| `cdp-idbroker-role` | EC2 trust policy | IDBroker role; assumed by EC2 instances |
| `cdp-logger-role` | EC2 trust policy | Logger role; assumed by EC2 instances |
| `cdp-datalake-admin-role` | IDBroker trust policy | Datalake admin role; assumed by IDBroker |
| `cdp-ranger-role` | IDBroker trust policy | Ranger audit role; assumed by IDBroker |

### IAM Policies (`roles.tf` + `policies/`)
| Policy | Attached To | Description |
|--------|-------------|-------------|
| `cdp-idbroker-assume-role-policy` | IDBroker role | Allows IDBroker to assume other CDP roles |
| `cdp-log-policy` | IDBroker role, Logger role | S3 permissions for writing logs |
| `cdp-backup-policy` | Logger role | S3 permissions for writing backups |
| `cdp-datalake-restore-policy` | Logger role, Ranger role, Datalake Admin role | S3 permissions for restoring Datalake data |
| `cdp-ranger-audit-s3-policy` | Ranger role | S3 permissions for Ranger audit logging |
| `cdp-bucket-access-policy` | Ranger role, Datalake Admin role | General S3 bucket access |
| `cdp-datalake-backup-policy` | Ranger role, Datalake Admin role | S3 permissions for Datalake backup operations |
| `cdp-datalake-admin-s3-policy` | Datalake Admin role | Full S3 permissions on the data storage location |

### EC2 Instance Profiles (`roles.tf`)
| Instance Profile | Role | Used For |
|-----------------|------|----------|
| `cdp-data-access-instance-profile` | IDBroker role | CDP data access |
| `cdp-log-access-instance-profile` | Logger role | CDP log access |

### SSH Key Pair (`ssh_key.tf`)
- Optionally creates an AWS EC2 key pair for SSH access to CDP instances. Only created when `ssh_key_name` is provided.

---

## Usage

```hcl
module "cdp_env_prerequisites" {
  source = "./aws/env-prerequisites"

  region          = "us-west-2"
  cdp_bucket_name = "my-cdp-bucket"

  ssh_key_name = "my-cdp-ssh-key"
  ssh_key      = "ssh-rsa AAAA... user@host"

  tags = {
    Environment = "production"
    Owner       = "data-platform-team"
  }
}
```

---

## Variables

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `region` | `string` | `"us-west-2"` | No | AWS region to deploy resources in |
| `cdp_bucket_name` | `string` | — | **Yes** | Name of the S3 bucket for CDP environment storage |
| `folders` | `object` | `{ data="data", logs="logs", backups="backups" }` | No | Names of the sub-folders to create in the S3 bucket |
| `ssh_key_name` | `string` | `""` | No | Name for the AWS EC2 key pair. If empty, no key pair is created |
| `ssh_key` | `string` | `null` | No | Public key material. If `ssh_key_name` is set but this is `null`, reads from `~/.ssh/id_rsa.pub` |
| `instance_profile_names` | `object` | `{ data_access="cdp-data-access-instance-profile", log_access="cdp-log-access-instance-profile" }` | No | Names for the EC2 instance profiles |
| `role_names` | `object` | See below | No | Names for the IAM roles |
| `policy_names` | `object` | See below | No | Names for the IAM policies |

### `role_names` defaults
```hcl
{
  idbroker       = "cdp-idbroker-role"
  datalake_admin = "cdp-datalake-admin-role"
  logger         = "cdp-logger-role"
  ranger         = "cdp-ranger-role"
}
```

### `policy_names` defaults
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

---

## Outputs

| Name | Description |
|------|-------------|
| `instance_profiles` | List of EC2 instance profile names created |
| `cdp_role_names` | Map of CDP IAM role names (`idbroker`, `data_admin`, `logger`, `ranger`) |
| `storage_locations` | List of S3 storage location paths (bucket + folder prefix) |
| `s3_bucket_id` | ARN of the CDP S3 bucket |
| `ssh_key_name` | Name of the created AWS key pair, or `null` if not created |

---

## IAM Role & Policy Attachment Summary

```
cdp-idbroker-role (EC2 trust)
  ├── cdp-idbroker-assume-role-policy
  └── cdp-log-policy

cdp-logger-role (EC2 trust)
  ├── cdp-log-policy
  ├── cdp-backup-policy
  └── cdp-datalake-restore-policy

cdp-ranger-role (IDBroker trust)
  ├── cdp-ranger-audit-s3-policy
  ├── cdp-bucket-access-policy
  ├── cdp-datalake-backup-policy
  └── cdp-datalake-restore-policy

cdp-datalake-admin-role (IDBroker trust)
  ├── cdp-datalake-admin-s3-policy
  ├── cdp-bucket-access-policy
  ├── cdp-datalake-backup-policy
  └── cdp-datalake-restore-policy
```

---

## Prerequisites

- Terraform >= 1.0
- AWS provider configured with sufficient permissions to create IAM roles, policies, S3 buckets, and EC2 key pairs
- The AWS account must be registered and cross-account role setup completed in Cloudera Management Console before deploying a CDP environment

## References

- [Cloudera CDP AWS Requirements — IDBroker Minimum Setup](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-idbroker-minimum-setup.html)
- [Cloudera CDP AWS IAM Policy Definitions](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-iam-policy-definitions.html)