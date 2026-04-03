# CDP Azure Environment Prerequisites Terraform Module

This module provisions the Azure infrastructure prerequisites required to register a Cloudera Data Platform (CDP) environment. It creates and configures the resource group, storage account, storage containers, user-assigned managed identities, and all required Azure RBAC role assignments.

## Features

- Optionally creates (or references an existing) Azure Resource Group
- Creates an ADLS Gen2-enabled Storage Account with three containers: `data`, `logs`, and `backups`
- Creates four required CDP managed identities: **assumer**, **dataaccess**, **logger**, and **ranger**
- Optionally creates a **RAZ** (Ranger Authorization Service) managed identity
- Assigns all required Azure RBAC roles to each managed identity
- Supports Customer-Managed Key (CMK) encryption readiness on the storage account

---

## Usage

```hcl
module "cdp_env_prerequisites" {
  source = "./azure/env-prerequisites"

  subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  location            = "eastus"
  resource_group_name = "my-cdp-rg"

  managed_id = {
    assumer    = "cdp-assumer-mi"
    dataaccess = "cdp-dataaccess-mi"
    logger     = "cdp-logger-mi"
    ranger     = "cdp-ranger-mi"
  }

  storage_account_name = "mycdpstorageacct"

  tags = {
    environment = "production"
    team        = "data-platform"
  }
}
```

### With RAZ Managed Identity

```hcl
module "cdp_env_prerequisites" {
  source = "./azure/env-prerequisites"

  subscription_id     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  location            = "eastus"
  resource_group_name = "my-cdp-rg"

  managed_id = {
    assumer    = "cdp-assumer-mi"
    dataaccess = "cdp-dataaccess-mi"
    logger     = "cdp-logger-mi"
    ranger     = "cdp-ranger-mi"
  }

  storage_account_name = "mycdpstorageacct"
  raz_mi_name          = "cdp-raz-mi"
}
```

### Using an Existing Resource Group

```hcl
module "cdp_env_prerequisites" {
  source = "./azure/env-prerequisites"

  subscription_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  create_resource_group = false
  resource_group_name   = "my-existing-rg"

  managed_id = {
    assumer    = "cdp-assumer-mi"
    dataaccess = "cdp-dataaccess-mi"
    logger     = "cdp-logger-mi"
    ranger     = "cdp-ranger-mi"
  }

  storage_account_name = "mycdpstorageacct"
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `subscription_id` | Azure Subscription ID where resources will be deployed | `string` | — | **Yes** |
| `resource_group_name` | Name of the CDP resource group | `string` | — | **Yes** |
| `managed_id` | Names for the four required managed identities (`assumer`, `dataaccess`, `logger`, `ranger`) | `object({ assumer, dataaccess, logger, ranger })` | — | **Yes** |
| `storage_account_name` | Name of the CDP Storage Account | `string` | — | **Yes** |
| `location` | Azure region where resources will be created | `string` | `"westus"` | No |
| `create_resource_group` | If `true`, creates the resource group. If `false`, references an existing one. | `bool` | `true` | No |
| `storage_locations` | Names of the storage containers for data, logs, and backups | `object({ data, logs, backups })` | `{ data = "data", logs = "logs", backups = "backups" }` | No |
| `obj_storage_performance` | Storage account tier and replication type | `object({ account_tier, replication })` | `{ account_tier = "Standard", replication = "LRS" }` | No |
| `raz_mi_name` | Name for the optional RAZ managed identity. Set to `null` to skip creation. | `string` | `null` | No |
| `tags` | Tags to apply to all created resources | `map(string)` | `null` | No |

---

## Outputs

| Name | Description |
|------|-------------|
| `storage` | DFS endpoint-based paths for storage, log, and backup locations |
| `storage_account` | Full storage account details including name, ID, resource group, and container names |
| `storage_locations` | Structured storage location strings suitable for CDP environment registration |
| `mi_ids` | Resource IDs for all managed identities (assumer, dataaccess, logger, ranger, raz) |
| `mi_principal_ids` | Principal IDs for all managed identities, used for role assignments and CDP registration |

---

## Resources Created

| Resource | Type | Description |
|----------|------|-------------|
| `azurerm_resource_group.prerequisite` | `azurerm_resource_group` | CDP resource group (conditional) |
| `azurerm_storage_account.cdp` | `azurerm_storage_account` | ADLS Gen2 storage account with HNS enabled |
| `azurerm_storage_container.containers` | `azurerm_storage_container` | Storage containers for data, logs, and backups |
| `azurerm_user_assigned_identity.managed_id` | `azurerm_user_assigned_identity` | Four required CDP managed identities |
| `azurerm_user_assigned_identity.raz` | `azurerm_user_assigned_identity` | Optional RAZ managed identity |
| `azurerm_role_assignment.assignment` | `azurerm_role_assignment` | RBAC role assignments for all core managed identities |
| `azurerm_role_assignment.raz` | `azurerm_role_assignment` | RBAC role assignments for the RAZ managed identity (conditional) |

---

## Role Assignments

The following Azure RBAC roles are assigned automatically:

### Assumer Identity
| Scope | Role |
|-------|------|
| Subscription | Managed Identity Operator |
| Subscription | Virtual Machine Contributor |
| `logs` container | Storage Blob Data Contributor |

### Data Access Identity
| Scope | Role |
|-------|------|
| `data` container | Storage Blob Data Owner |
| `logs` container | Storage Blob Data Owner |
| `backups` container | Storage Blob Data Owner |

### Logger Identity
| Scope | Role |
|-------|------|
| `logs` container | Storage Blob Data Contributor |
| `backups` container | Storage Blob Data Contributor |
| Storage Account | Storage Account Contributor |

### Ranger Identity
| Scope | Role |
|-------|------|
| `data` container | Storage Blob Data Contributor |
| `logs` container | Storage Blob Data Contributor |
| `backups` container | Storage Blob Data Contributor |

### RAZ Identity *(optional)*
| Scope | Role |
|-------|------|
| Storage Account | Storage Blob Data Owner |
| Storage Account | Storage Blob Delegator |

---

## Notes

- The storage account is created as **StorageV2** with **Hierarchical Namespace (HNS)** enabled, making it an ADLS Gen2-compatible account.
- The storage account is pre-configured with a `SystemAssigned, UserAssigned` identity to support future Customer-Managed Key (CMK) encryption. Changes to `customer_managed_key` are ignored in the lifecycle to allow external key rotation.
- When `raz_mi_name` is `null` (the default), no RAZ managed identity or associated role assignments are created.
- All four managed identity names (`assumer`, `dataaccess`, `logger`, `ranger`) are required even if you choose to use existing identities — this module always creates new ones.