# CDP Prerequisite Module

A collection of Terraform modules that provision Cloudera Data Platform (CDP) Public Cloud prerequisite resources on **AWS** and **Azure**.

CDP onboarding requires more than basic object storage — depending on your configuration (CMK encryption, reduced permissions, private DNS, data services, etc.), a number of cloud-managed resources must exist before a CDP environment can be registered. This repository organises those resources into focused, composable modules that cover the most common CDP onboarding scenarios.

---

## Repository Structure

```
cdp-prerequisite-module/
├── aws/
│   ├── xaccount-role/             # Cross-account IAM role for Cloudera control plane
│   ├── env-prerequisites/         # S3 bucket, IAM roles, instance profiles, SSH key
│   ├── cmk-prerequisites/         # AWS KMS customer-managed key + IAM policies
│   └── data-services-prerequisites/  # Reduced permissions for CDP Data Services
└── azure/
    ├── service-principal/         # Azure Service Principal + role assignment for CDP credential
    ├── env-prerequisites/         # Storage account, managed identities, RBAC assignments
    ├── cmk-prerequisites/         # Azure Key Vault + key + access policies
    ├── cdp-custom-role-permissions/   # Custom RBAC role definitions for CDP
    ├── managed-identity-rbac/     # Role assignments for Data Services & CMK managed identities
    ├── nfs-prerequisites/         # NFS file share on Azure Storage (for ML workspaces)
    └── dns-zone-role-assignment/  # Role assignments for cross-subscription private DNS zones
```

---

## AWS Modules

### `xaccount-role`
Creates or configures the cross-account IAM role that allows the Cloudera control plane to provision resources in your AWS account. Supports both creating a new role and attaching the required policies to an existing one.

→ [Module README](aws/xaccount-role/README.MD)

### `env-prerequisites`
Provisions the core CDP environment prerequisites:
- S3 bucket with `data/`, `logs/`, and `backups/` folders
- Four IAM roles: IDBroker, Logger, Datalake Admin, and Ranger Audit
- Two EC2 instance profiles: data access and log access
- Optionally, an EC2 SSH key pair

→ [Module README](aws/env-prerequisites/README.MD)

### `cmk-prerequisites`
Creates an AWS KMS customer-managed key and attaches the required IAM policies to existing CDP IAM roles to enable CMK encryption for CDP resources.

→ [Module README](aws/cmk-prerequisites/README.MD)

### `data-services-prerequisites`
Configures the additional IAM permissions needed by the cross-account role when **reduced permission mode** is selected for CDP Data Services (Data Engineering, Data Warehouse, DataFlow, and Machine Learning). Includes a CloudFormation stack for the Liftie (EKS) role pair.

→ [Module README](aws/data-services-prerequisites/README.MD)

---

## Azure Modules

### `service-principal`
Creates an Azure Active Directory Service Principal and assigns it the roles required to register a CDP credential in the Cloudera Management Console. Designed to be run independently, as Service Principal management is often handled by a separate IAM team.

→ [Module README](azure/service-principal/README.MD)

### `env-prerequisites`
Provisions the core CDP environment prerequisites on Azure:
- Resource group (optional — can reference an existing one)
- ADLS Gen2 storage account with `data`, `logs`, and `backups` containers
- Four user-assigned managed identities: assumer, dataaccess, logger, and ranger
- Optionally, a RAZ (Ranger Authorization Service) managed identity
- All required Azure RBAC role assignments for each managed identity

→ [Module README](azure/env-prerequisites/README.MD)

### `cmk-prerequisites`
Creates an Azure Key Vault and key for Customer-Managed Key (CMK) encryption, and configures access policies for the Service Principal, the encryption managed identity, and the Terraform runner.

→ [Module README](azure/cmk-prerequisites/README.MD)

### `cdp-custom-role-permissions`
Calculates and outputs the Azure RBAC action sets required for CDP custom roles — covering environment operations, Data Engineering, Data Warehouse, DataFlow, Liftie (AKS), CMK, and private DNS. Useful for teams that need to define custom roles rather than use built-in Azure roles.

→ [Module README](azure/cdp-custom-role-permissions/README.MD)

### `managed-identity-rbac`
Assigns Azure RBAC roles to managed identities used during CDP Data Services provisioning and CMK-related operations. Run this after `env-prerequisites` and `cmk-prerequisites` when deploying data services with reduced permissions.

→ [Module README](azure/managed-identity-rbac/README.MD)

### `nfs-prerequisites`
Creates an NFS file share on an Azure Storage account for use with CDP Machine Learning workspaces. Supports optional CMK encryption of the file share.

→ [Module README](azure/nfs-prerequisites/README.MD)

### `dns-zone-role-assignment`
Assigns the required roles to the Service Principal and managed identities on private DNS zones that exist in a **different subscription** from the CDP resource subscription. Only required in cross-subscription private DNS configurations.

→ [Module README](azure/dns-zone-role-assignment/README.MD)

---

## AWS Quick Start

The example below provisions a complete set of AWS prerequisites — cross-account role, environment resources, and CMK — in a single root module call.

```hcl
module "prerequisite" {
  source = "<path-to-this-repo>//aws"

  cross_account_role = {
    name        = "cdp-poc-xaccount-role"
    create_role = true           # set false to use an existing role
  }

  cdp_bucket_name = "cdp-poc-bucket"

  ssh_key = {
    name = "my-cdp-ssh-key"
    key  = file("~/.ssh/id_rsa.pub")
  }

  cmk = {
    key_alias  = "my-cdp-kms-key"
    create_key = true            # set false to use an existing key
  }

  tags = {
    owner       = "data-platform-team"
    environment = "production"
  }
}

output "prerequisite" {
  value = module.prerequisite
}
```

### AWS Variable Reference

| Variable | Required | Default | Description |
|---|---|---|---|
| `region` | No | `us-west-2` | AWS region for all resources |
| `cdp_bucket_name` | **Yes** | — | Name of the S3 bucket for CDP |
| `folders` | No | `data`, `logs`, `backups` | Sub-folder names inside the S3 bucket |
| `cross_account_role` | **Yes** | — | Object with `name` (role name) and `create_role` (bool) |
| `ssh_key` | No | `null` | Object with `name` and `key` (public key material). If omitted, no key pair is created |
| `cmk` | No | `null` | Object with `key_alias` and `create_key` (bool). If omitted, no CMK is configured |
| `aws_sso_user_arn_keyword` | No | random string | ARN keyword for administrator trust on the cross-account role |
| `use_raz` | No | `null` | RAZ support — not yet implemented |
| `tags` | No | `{}` | Tags to apply to all created resources |
| `role_names` | No | See below | Custom names for the four CDP IAM roles |
| `policy_names` | No | See below | Custom names for all CDP IAM policies |
| `instance_profile_names` | No | See below | Custom names for the two EC2 instance profiles |

**`role_names` defaults:**
```hcl
{
  idbroker       = "CDP_IDBROKER"
  logger         = "CDP_LOG_ROLE"
  ranger         = "CDP_RANGER_AUDIT"
  datalake_admin = "CDP_DATALAKE_ADMIN"
}
```

**`instance_profile_names` defaults:**
```hcl
{
  data_access = "cdp-data-access-instance-profile"
  log_access  = "cdp-log-access-instance-profile"
}
```

---

## Azure Quick Start

Azure onboarding typically requires running multiple modules. The recommended order is:

1. `service-principal` — if your IAM team is not managing the SPN separately
2. `env-prerequisites` — core storage and managed identities
3. `cmk-prerequisites` — if using CMK encryption
4. `managed-identity-rbac` — if deploying data services or using CMK
5. `nfs-prerequisites` — if deploying CDP Machine Learning
6. `dns-zone-role-assignment` — if private DNS zones are in a separate subscription

Refer to each module's README for its own usage example and variable reference.

---

## Requirements

| Tool | Minimum Version |
|---|---|
| Terraform | >= 1.0 |
| AWS Provider | >= 4.0 |
| AzureRM Provider | >= 3.0 |

---

## Changelog

See [CHANGELOG.MD](CHANGELOG.MD) for the full version history.

---

## References

- [Cloudera CDP Public Cloud — AWS Requirements](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-idbroker-minimum-setup.html)
- [Cloudera CDP Public Cloud — Azure Requirements](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-azure/topics/mc-azure-requirements.html)
- [Cloudera CDP IAM Policy Definitions (AWS)](https://docs.cloudera.com/cdp-public-cloud/cloud/requirements-aws/topics/mc-iam-policy-definitions.html)