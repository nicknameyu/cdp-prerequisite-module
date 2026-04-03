# DNS Zone Role Assignment

This Terraform module creates role assignments for a Service Principal and Managed Identity to perform the required private DNS zone operations in Azure. It is intended for use in cross-subscription scenarios where the private DNS zones reside in a **different subscription** than the CDP (Cloudera Data Platform) resources.

The module supports two role assignment modes:
- **Built-in role** (default): Assigns the Azure built-in `Private DNS Zone Contributor` role.
- **Custom role** (optional): Creates and assigns a custom role with a minimal set of permissions sourced from the [`cdp-custom-role-permissions`](https://github.com/nicknameyu/cdp-prerequisite-module/tree/main/azure/cdp-custom-role-permissions) module.

---

## Architecture

```
┌────────────────────────────┐       ┌──────────────────────────────────────┐
│  CDP Resource Subscription │       │  DNS Zone Subscription               │
│                            │       │                                      │
│  - Service Principal (SPN) │──────▶│  Role Assignment (DNS Zone Contrib   │
│  - Managed Identity (MI)   │       │  or Custom Role) @ Subscription or   │
│                            │       │  Resource Scope                      │
└────────────────────────────┘       └──────────────────────────────────────┘
```

---

## Usage

### Minimal (built-in role, subscription scope)

```hcl
module "dns_zone_role_assignment" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/dns-zone-role-assignment"

  providers = {
    azurerm.dns_zone = azurerm.secondary
  }

  principal_ids = {
    spn = "<SPN Object ID>"
    mi  = "<Managed Identity Principal ID>"
  }
}
```

### Custom role with a specific assignment scope

```hcl
module "dns_zone_role_assignment" {
  source = "github.com/nicknameyu/cdp-prerequisite-module/azure/dns-zone-role-assignment"

  providers = {
    azurerm.dns_zone = azurerm.secondary
  }

  principal_ids    = {
    spn = "<SPN Object ID>"
    mi  = "<Managed Identity Principal ID>"
  }

  use_custom_role  = true
  custom_role_name = "CDP DNS Zone Operator"
  assign_scope     = "/subscriptions/<dns-subscription-id>/resourceGroups/<dns-rg>"
}
```

---

## Provider Configuration

This module requires an **aliased provider** targeting the subscription that hosts the private DNS zones. Configure it in your root module:

```hcl
provider "azurerm" {
  alias           = "secondary"
  subscription_id = "<dns-zone-subscription-id>"
  features {}
}
```

Pass the aliased provider to the module via the `providers` argument (see examples above).

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

---

## Providers

| Name | Description |
|------|-------------|
| `azurerm.dns_zone` | **Required alias.** Targets the Azure subscription where the private DNS zones are hosted. |

---

## Inputs

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `principal_ids` | `map(string)` | — | **Yes** | Map of principal IDs to be assigned the role. Recommended keys: `spn` (Service Principal object ID) and `mi` (Managed Identity principal ID). |
| `use_custom_role` | `bool` | `false` | No | When `true`, creates a custom role with minimum required permissions instead of using the built-in `Private DNS Zone Contributor` role. |
| `custom_role_name` | `string` | `null` | No | Name for the custom role. Required when `use_custom_role = true`. |
| `assign_scope` | `string` | `null` | No | Scope at which to assign the role. Defaults to the subscription level of the DNS zone provider. Can be narrowed to a specific resource group or resource. |

---

## Outputs

This module does not define explicit outputs.

---

## Resources Created

| Resource | Condition | Description |
|----------|-----------|-------------|
| `azurerm_role_definition.dns_zone` | `use_custom_role = true` | Custom role with CDP-specific DNS zone permissions at subscription scope. |
| `azurerm_role_assignment.dns_zone` | Always (one per entry in `principal_ids`) | Assigns the selected role to each principal at the configured scope. |

---

## Notes

- This module is part of the broader [CDP Prerequisite Module](https://github.com/nicknameyu/cdp-prerequisite-module) collection for Azure.
- Use this module **only** when your private DNS zones live in a separate subscription from your CDP resources. For same-subscription deployments, role assignments are typically handled inline.
- When using `use_custom_role = true`, the custom role permissions are pulled from the sibling [`cdp-custom-role-permissions`](https://github.com/nicknameyu/cdp-prerequisite-module/tree/main/azure/cdp-custom-role-permissions) module and scoped to the DNS zone subscription.
- The `assign_scope` variable allows you to restrict the blast radius of the role assignment to a specific resource group or DNS zone resource rather than the full subscription.