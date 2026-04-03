# cdp-custom-role-permissions

A Terraform module that computes the minimum required Azure custom role permissions for deploying and operating [Cloudera Data Platform (CDP)](https://www.cloudera.com/products/cloudera-data-platform.html) on Azure. The module does **not** create any Azure resources — it outputs consolidated permission lists that you can feed into an `azurerm_role_definition` resource or use as a reference when configuring custom RBAC roles manually.

## Overview

CDP on Azure requires a Service Principal (SPN) and one or more Managed Identities (MIs) to have specific Azure RBAC permissions. The exact set of permissions depends on which CDP services are enabled in your environment. This module lets you toggle individual service flags and receive a deduplicated, merged permission list for each principal type.

## Outputs

| Name | Description |
|------|-------------|
| `spn_permissions` | Merged `actions` and `data_actions` for the CDP Service Principal, plus the recommended scope (`CDP Subscription`). |
| `mi_permissions` | Merged `actions` and `data_actions` for Managed Identities, plus the recommended scope (`CDP Subscription`). |
| `dns_zone_permissions` | Actions required on an external Private DNS Zone subscription (if DNS zones live outside the CDP subscription). |

### Output structure

Both `spn_permissions` and `mi_permissions` return an object:

```hcl
{
  actions      = [ ... ]   # list of ARM action strings
  data_actions = [ ... ]   # list of ARM data-action strings
  scope        = "CDP Subscription"
}
```

`dns_zone_permissions` returns a plain `list(string)` of ARM action strings.

## Usage

```hcl
module "cdp_custom_role_permissions" {
  source = "github.com/nicknameyu/cdp-prerequisite-module//azure/cdp-custom-role-permissions"

  enable_cmk    = true
  enable_dw     = true
  enable_liftie = true
  enable_de     = true
}

# Example: create a custom role for the SPN from the computed permissions
resource "azurerm_role_definition" "cdp_spn_role" {
  name        = "CDP SPN Custom Role"
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Minimum permissions for the CDP Service Principal"

  permissions {
    actions      = module.cdp_custom_role_permissions.spn_permissions.actions
    data_actions = module.cdp_custom_role_permissions.spn_permissions.data_actions
  }

  assignable_scopes = ["/subscriptions/${var.subscription_id}"]
}
```

See the [`test/`](./test/main.tf) directory for a working example.

## Input Variables

### Feature flags

These flags control which service-specific permission sets are merged into the final output. All default to `true`.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_dw` | `bool` | `true` | Include permissions required for **CDP Data Warehouse**. |
| `enable_liftie` | `bool` | `true` | Include permissions required for **Liftie** (the Kubernetes cluster manager used by ML and other services). |
| `enable_de` | `bool` | `true` | Include permissions required for **CDP Data Engineering**. |
| `enable_cmk` | `bool` | `true` | Include permissions required for **Customer-Managed Keys (CMK)** via Azure Key Vault. |
| `enable_dns_zone_subscription` | `bool` | `true` | Indicates that Private DNS zones reside in a subscription other than the CDP subscription. When `true`, `dns_zone_permissions` provides the actions to assign on the remote subscription. |

### Permission list overrides

Each permission list has a sensible default but can be overridden if your environment requires additions or removals.

| Variable | Type | Description |
|----------|------|-------------|
| `env_reduced_permission_actions` | `list(string)` | Base actions for the SPN covering FreeIPA, Datalake, and Datahub. Includes storage, networking, compute, PostgreSQL, and Marketplace permissions. |
| `env_reduced_permission_data_actions` | `list(string)` | Base data actions for the SPN and MI covering blob storage read/write/delete. |
| `dw_actions` | `list(string)` | Additional actions merged in when `enable_dw = true`. Covers AKS cluster management, load balancers, route tables, and private endpoints. |
| `liftie_actions` | `list(string)` | Additional actions merged in when `enable_liftie = true`. Covers AKS, VMSS, managed identity federation, route tables, and Azure Monitor metrics. |
| `de_actions` | `list(string)` | Additional actions merged in when `enable_de = true`. Covers Azure Database for MySQL flexible server lifecycle and private endpoint approval. |
| `cmk_rbac_actions` | `list(string)` | Additional actions merged in when `enable_cmk = true`. Covers Key Vault read/write and Disk Encryption Sets. |
| `cmk_rbac_data_actions` | `list(string)` | Additional data actions merged in when `enable_cmk = true`. Covers Key Vault key operations (wrap, unwrap, encrypt, decrypt, sign, verify, backup). |
| `dns_zone_actions` | `list(string)` | Actions required on a remote Private DNS Zone subscription. Returned directly via the `dns_zone_permissions` output. |

## Permission Sets by Service

### Base environment (FreeIPA / Datalake / Datahub) — always included

Covers the core Azure resources that every CDP environment requires:

- **Storage** — storage account and blob container lifecycle
- **Networking** — VNets, subnets, NSGs, public IPs, NICs, load balancers, private endpoints, private DNS zones
- **Compute** — VMs, disks, images, availability sets
- **PostgreSQL** — flexible server lifecycle and private endpoint management
- **Resources** — resource group reads, ARM deployments
- **Managed Identity** — reading and assigning user-assigned identities
- **Marketplace** — accepting offer agreements

### Data Warehouse (`enable_dw`)

- AKS managed cluster and agent pool lifecycle
- Route tables and service endpoint joins
- Private DNS zones and private endpoints

### Liftie (`enable_liftie`)

- AKS managed cluster and agent pool lifecycle (including upgrades)
- Virtual Machine Scale Sets
- Managed identity federated credentials
- Azure Monitor metrics and metric definitions
- Route tables, private DNS zones, and private endpoints

### Data Engineering (`enable_de`)

- Azure Database for MySQL flexible server lifecycle (create, read, update, delete, start, stop)
- Firewall rules and private endpoint connection approval

### Customer-Managed Keys (`enable_cmk`)

- Key Vault vault, secret, and key management
- Disk Encryption Sets
- Key Vault key operations: wrap/unwrap, encrypt/decrypt, sign/verify, backup

### External Private DNS Zone (`enable_dns_zone_subscription`)

- Read/write/delete on private DNS zones and A records
- Virtual network link reads and join actions

## Notes

- All permission lists are **deduplicated** using Terraform's `distinct()` function before being returned, so overlapping permissions across services are merged cleanly.
- The `mi_permissions` output intentionally excludes the base `env_reduced_permission_actions` (SPN-only actions) and contains only the subset relevant to Managed Identities (DW, Liftie, CMK, and blob data actions).
- The `dns_zone_permissions` output should be used to create a role assignment in the **DNS zone subscription**, separate from the main CDP subscription role.
- For the built-in alternative to a custom DNS zone role, Azure's `Private DNS Zone Contributor` built-in role covers the same set of actions.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |

No provider is required — this module outputs computed values only and does not manage any Azure resources itself.