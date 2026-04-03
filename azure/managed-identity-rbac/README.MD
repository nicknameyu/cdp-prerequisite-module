# Cloudera Data Services – Managed Identity RBAC Prerequisites

This module creates custom role definitions and role assignments for the Managed Identity required by Cloudera Data Services (Data Warehouse, Data Engineering, DataFlow, Cloudera AI) on Azure. It also supports Customer-Managed Key (CMK) RBAC permissions.

The Managed Identity needs specific permissions to manage AKS clusters and PostgreSQL/MySQL database operations. These permissions are scoped at the subscription level and are not required for CDP Datalake or DataHub, which use a Service Principal instead.

## Features

- Optionally creates a custom Azure role with permissions scoped to the subscription.
- Supports reuse of an existing custom role by name.
- Assigns the custom role and the built-in `Managed Identity Operator` role to the specified Managed Identity principal.
- Toggleable permission sets for Data Warehouse, Liftie-based services (Data Engineering, DataFlow, Cloudera AI), and CMK RBAC.
- Includes a 300-second delay after custom role creation to avoid race conditions during role assignment.

## Usage

```hcl
module "managed_identity_rbac" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/managed-identity-rbac"

  subscription_id    = "<azure-subscription-id>"
  mi_principal_id    = "<managed-identity-principal-id>"
  custom_role_name   = "cdp-data-services-custom-role"
  create_custom_role = true

  enable_dw       = true
  enable_liftie   = true
  enable_cmk_rbac = true
}
```

## Inputs

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `subscription_id` | `string` | — | **Yes** | Azure subscription ID. Role assignments and role definitions are scoped to this subscription. |
| `mi_principal_id` | `string` | — | **Yes** | Principal ID of the Data Access Managed Identity to be granted the custom role. |
| `custom_role_name` | `string` | `null` | No | Name of the custom role. If `create_custom_role` is `false` and this is set, the module will look up an existing role by this name. If `create_custom_role` is `true`, the module creates a new role with this name. If `null`, no custom role assignment is made. |
| `create_custom_role` | `bool` | `false` | No | When `true`, creates a new Azure custom role definition. When `false`, an existing role is used. |
| `enable_dw` | `bool` | `true` | No | Enables Data Warehouse permissions in the custom role. |
| `enable_liftie` | `bool` | `true` | No | Enables Liftie-based service permissions (Data Engineering, DataFlow, Cloudera AI) in the custom role. |
| `enable_cmk_rbac` | `bool` | `true` | No | Enables Customer-Managed Key (CMK) RBAC permissions in the custom role. |

## Role Assignments

When `custom_role_name` is provided, the module creates the following role assignments for the Managed Identity at the subscription scope:

| Role | Notes |
|------|-------|
| `<custom_role_name>` | Custom role containing AKS and DB encryption permissions. |
| `Managed Identity Operator` | Built-in Azure role. Required but not explicitly listed in CDP documentation. |

## Notes

- **Role propagation delay**: When `create_custom_role = true`, a 5-minute (`300s`) delay is introduced between role creation and assignment to allow Azure to propagate the new role definition. This is expected behaviour.
- **Permission composition**: The actual permission actions included in the custom role are sourced from the [`cdp-custom-role-permissions`](https://github.com/nicknameyu/cdp-prerequisite-module/azure/cdp-custom-role-permissions) module and are controlled by the `enable_dw`, `enable_liftie`, and `enable_cmk_rbac` flags.
- **Existing custom role**: If you already have a custom role with the required permissions, set `create_custom_role = false` and provide the role name via `custom_role_name` to skip role creation and go straight to assignment.

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.0` |
| `azurerm` | `>= 3.0` |
| `time` | `>= 0.9` |