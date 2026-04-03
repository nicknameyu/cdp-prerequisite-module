# Azure Service Principal Module for CDP

This Terraform module provisions the Azure prerequisites needed to create a **Cloudera Data Platform (CDP) credential**. It handles Service Principal creation and/or role assignment at the subscription scope, including optional custom role creation with fine-grained permission sets.

> **Note:** This module does not create a CDP credential directly. It prepares the Azure identity and permissions so a credential can be registered in the Cloudera UI.

---

## Features

- Create a new Azure AD Service Principal (app registration + SP + password), or reference an existing one
- Assign the `Contributor` role, or a custom role, to the SPN at subscription scope
- Optionally create a custom Azure role with reduced permissions tailored for CDP workloads
- Modular permission groups for CDP Datahub, CMK, Data Warehouse, Liftie, and Data Engineering

---

## Usage

### Create a new SPN with the default Contributor role

```hcl
module "cdp_service_principal" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/service-principal"

  subscription_id = "<your-subscription-id>"
  tenant_id       = "<your-tenant-id>"
  spn_app_name    = "my-cdp-spn"
  create_spn      = true
}
```

### Use an existing SPN (by name)

```hcl
module "cdp_service_principal" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/service-principal"

  subscription_id = "<your-subscription-id>"
  tenant_id       = "<your-tenant-id>"
  spn_app_name    = "my-existing-spn"
  create_spn      = false
}
```

### Use an existing SPN (by Object ID)

```hcl
module "cdp_service_principal" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/service-principal"

  subscription_id = "<your-subscription-id>"
  tenant_id       = "<your-tenant-id>"
  spn_object_id   = "<spn-object-id>"
  create_spn      = false
}
```

### Create a new SPN with a custom role (reduced permissions)

```hcl
module "cdp_service_principal" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/service-principal"

  subscription_id    = "<your-subscription-id>"
  tenant_id          = "<your-tenant-id>"
  spn_app_name       = "my-cdp-spn"
  create_spn         = true
  create_custom_role = true
  custom_role_name   = "CDP Custom Role"

  # Optionally disable specific permission groups
  enable_dw       = true
  enable_cmk_rbac = true
  enable_liftie   = true
  enable_de       = true
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |
| azuread | >= 2.0 |
| time | >= 0.9 |

---

## Providers

| Name | Purpose |
|------|---------|
| `azuread` | Manages Azure AD application, service principal, and password |
| `azurerm` | Manages Azure role definitions and role assignments |
| `time` | Introduces a delay after custom role creation to allow Azure propagation |

---

## Variables

### Required

| Name | Type | Description |
|------|------|-------------|
| `subscription_id` | `string` | Azure Subscription ID used as the scope for role assignments. |
| `tenant_id` | `string` | Azure AD Tenant ID. |

### Service Principal

Exactly one of `spn_app_name` or `spn_object_id` must be provided.

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_spn` | `bool` | `false` | When `true`, creates a new Azure AD app registration and service principal. When `false`, an existing SPN is looked up. |
| `spn_app_name` | `string` | `null` | Display name of the app/SPN. Required when `create_spn = true`. Can also be used to look up an existing SPN by name. |
| `spn_object_id` | `string` | `null` | Object ID of an existing SPN. Use this instead of `spn_app_name` to reference an existing SPN by ID. |

> **Validation:** Exactly one of `spn_object_id` or `spn_app_name` must be set — not both and not neither.

### Role Assignment

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_custom_role` | `bool` | `false` | When `true`, creates a custom Azure role with reduced permissions and assigns it to the SPN. |
| `custom_role_name` | `string` | `null` | Name of the custom role to create or assign. Required when `create_custom_role = true`. When not provided, the built-in `Contributor` role is used. |

### Permission Groups (used when `create_custom_role = true`)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enable_dw` | `bool` | `true` | Include permissions required for CDP Data Warehouse. |
| `enable_cmk_rbac` | `bool` | `true` | Include permissions required for Customer-Managed Keys (CMK). |
| `enable_liftie` | `bool` | `true` | Include permissions required for Liftie (AKS-based workloads). |
| `enable_de` | `bool` | `true` | Include permissions required for CDP Data Engineering. |

---

## Outputs

| Name | Description |
|------|-------------|
| `service_principal` | An object containing the SPN's `client_id`, `object_id`, and `secret`. The `secret` is only available when `create_spn = true`; otherwise it returns `"Not Available"`. |

Example output:

```hcl
service_principal = {
  client_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  object_id = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
  secret    = "<sensitive-value>"   # only when create_spn = true
}
```

> **Security:** Mark the `secret` output as sensitive in downstream configurations. Do not commit it to source control.

---

## Resources Created

| Resource | Condition |
|----------|-----------|
| `azuread_application.xaccount` | `create_spn = true` |
| `azuread_service_principal.xaccount` | `create_spn = true` |
| `azuread_service_principal_password.xaccount` | `create_spn = true` |
| `azurerm_role_definition.reduced` | `create_custom_role = true` |
| `azurerm_role_assignment.xaccount` | Always |
| `time_sleep.custom_role` | Always (1s delay by default, 300s when `create_custom_role = true`) |

---

## Notes

- **Role propagation delay:** When `create_custom_role = true`, the module waits **300 seconds** after role definition creation before assigning the role. This accounts for Azure AD replication lag and avoids race conditions.
- **Role scope:** Role assignments are scoped to the entire subscription (`/subscriptions/<id>`).
- **Custom role permissions:** Permission sets are sourced from the sibling module [`cdp-custom-role-permissions`](../cdp-custom-role-permissions/). Each permission group (`enable_dw`, `enable_cmk_rbac`, etc.) toggles actions in that module.
- **Existing SPN lookup:** When `create_spn = false`, the SPN is looked up via `azuread_service_principal` data source using either `spn_app_name` or `spn_object_id`.

---

## Related Modules

- [`azure/cdp-custom-role-permissions`](../cdp-custom-role-permissions/) — Defines the permission action sets used by the custom role in this module.