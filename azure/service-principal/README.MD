# Azure Service Principal Module for CDP

This Terraform module provisions the Azure prerequisites needed to create a **Cloudera Data Platform (CDP) credential**. It handles Service Principal creation and/or role assignment at the subscription scope, including optional custom role creation with fine-grained permission sets.

> **Note:** This module does not create a CDP credential directly. It prepares the Azure identity and permissions so a credential can be registered in the Cloudera UI.

---

## Features

- Create a new Azure AD Service Principal (app registration + SP + password), or reference an existing one
- Assign the `Contributor` role, or a custom role, to the SPN at a calculated scope
- Optionally assign the `Contributor` role, or a custom role, to the CMK/DS Managed identity at a calculated scope
- Optionally create a custom Azure role with reduced permissions tailored for CDP workloads
- Modular permission groups for CDP Datahub, CMK, Data Warehouse, Liftie, and Data Engineering
- Assign different roles for different purpose per calculating based on the input. 
  - "Key Vault Crypto Service Encryption User" for Key Vault
  - "Private DNS Zone Contributor" for private DNS Zone
  - "Network Contributor" for VNET
---

## Usage

### Create a new SPN with the default Contributor role

```hcl
module "cdp_service_principal" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/service-principal"

  subscription_id = "<your-subscription-id>"
  tenant_id       = "<your-tenant-id>"
  spn_app_name    = "my-cdp-spn"
  mi_object_id    = "<object id of the cmk and ds managed identity>"
  key_vault_id    = "<key vault ID>"

  private_dns_zone_resource_group_id = "<private dns zone resource group id>"
  vnet_resource_group_id             = "<vnet resource group id>"
}
```

### Use an existing SPN (by object id)

```hcl
module "cdp_service_principal" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/service-principal"

  subscription_id = "<your-subscription-id>"
  tenant_id       = "<your-tenant-id>"
  spn_object_id   = "<SPN object ID>"
  mi_object_id    = "<object id of the cmk and ds managed identity>"
  key_vault_id    = "<key vault ID>"

  private_dns_zone_resource_group_id = "<private dns zone resource group id>"
  vnet_resource_group_id             = "<vnet resource group id>"
}
```

### Create a new SPN with a custom role (reduced permissions)

```hcl
module "cdp_service_principal" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/service-principal"

  subscription_id    = "<your-subscription-id>"
  tenant_id          = "<your-tenant-id>"
  spn_app_name       = "my-cdp-spn"
  create_custom_role = true
  custom_role_name   = "CDP Custom Role"

  mi_object_id    = "<object id of the cmk and ds managed identity>"
  key_vault_id    = "<key vault ID>"

  private_dns_zone_resource_group_id = "<private dns zone resource group id>"
  vnet_resource_group_id             = "<vnet resource group id>"

  # Optionally disable specific permission groups
  enable_dw       = true
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
This part is different to the official documentation. The doc recommends to either us contributor role or include all the permissions in one custom role, which is not the best practice in most Azure customers.
The Best practice is:
- Do not grant permission at subscription level, cause that will introduce too much risks.
- Contributor role at CDP resource group level. All resources in this resource group are CDP resources, so contributor permission is safe.
- Network is in another resource group. An Azure built-in role should be used.
- Private DNS zones are in HUB subscription together with the HUB VNET. So an Azure built-in role should be used on the private DNS zone resource group.
- Key Vault is in another resource group or even another subscription. So an Azure built-in role should be used on the key vault.

RBAC follows these assumptions and design:
- SPN and Managed identity(if provided) share the same RBAC. Because when managed identity is provided, it means CMK and AKS are probably involved, which means whatever RBAC is on SPN must also be assigned to the managed identity.
- If CMK is enabled, and KeyVault is in another subscription, `Key Vault Crypto Service Encryption User` need to be assigned at the KeyVaul for the principals.
- If private DNS zone resource group is in another subscription, `Private DNS zone contributor` need to be assigned at the private DNS zone resource group. 
- If the RBAC for principals is at subscription level:
  - If `contributor` is allowed, no other permission assignment is required.
  - If `contributor` is not allowed, calculate required permission with `cdp-custom-role-permissions` module and create custom role.
- If the RBAC for pricipals is at resource group level:
  - By default assign `contributor` role at CDP resrouce groups. 
  - If `contributor` is not allowed, calculate required permission with `cdp-custom-role-permissions` module and create custom role.
  - If network resource group is provided, `Network Contributor` role is required at network resource group. 


| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_custom_role` | `bool` | `false` | When `true`, creates a custom Azure role with reduced permissions and assigns it to the SPN. |
| `custom_role_name` | `string` | `null` | Name of the custom role to create or assign. Required when `create_custom_role = true`. When not provided, the built-in `Contributor` role is used. |

### Permission Groups (used when `create_custom_role = true`)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `enable_dw` | `bool` | `true` | Include permissions required for CDP Data Warehouse. |
| `key_vault_id` | `string` | `null`l | Include permissions required for Customer-Managed Keys (CMK) if not `null`. |
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
| `azuread_application.xaccount` | `spn_app_name != null` |
| `azuread_service_principal_password.xaccount` | `spn_app_name != null` |
| `azurerm_role_definition.reduced` | `create_custom_role = true` |
| `azurerm_role_assignment.xaccount` | Always |
| `azurerm_role_assignment.vnet` | multiple calculation |
| `azurerm_role_assignment.kv` | multiple calculation |
| `azurerm_role_assignment.dns_zone` | multiple calculation |
| `time_sleep.custom_role` | Always (1s delay by default, 300s when `create_custom_role = true`) |

---

## Notes

- **Role propagation delay:** When `create_custom_role = true`, the module waits **300 seconds** after role definition creation before assigning the role. This accounts for Azure AD replication lag and avoids race conditions.
- **Role scope:** VNET RBAC is sometimes scoped to the entire subscription (`/subscriptions/<id>`) even the VNET resource group ID is provided.
- **Custom role permissions:** Permission sets are sourced from the sibling module [`cdp-custom-role-permissions`](../cdp-custom-role-permissions/). Each permission group (`enable_dw`, `enable_liftie`, etc.) toggles actions in that module.
- **Existing SPN lookup:** When `spn_app_name = null`, the SPN is looked up via `azuread_service_principal` data source using `spn_object_id`.

---

## Related Modules

- [`azure/cdp-custom-role-permissions`](../cdp-custom-role-permissions/) — Defines the permission action sets used by the custom role in this module.