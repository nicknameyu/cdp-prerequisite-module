# cmk-prerequisites

A Terraform module for provisioning Azure **Customer-Managed Key (CMK)** prerequisites required by Cloudera Data Platform (CDP). The module creates or adopts an existing Azure Key Vault, generates an RSA key with automatic rotation, and optionally configures Key Vault access policies and storage account CMK encryption.

---

## Features

- Create a new Azure Key Vault (Premium SKU, purge-protection enabled) **or** reference an existing one
- Create an RSA-2048 CMK with a 90-day expiry and automatic 30-day pre-expiry rotation
- Optionally configure Key Vault access policies for a Service Principal, a User-Assigned Managed Identity, and the Terraform caller
- Optionally attach the CMK to an Azure Storage Account for customer-managed encryption

---

## Usage

### Minimal — create Key Vault and key, RBAC authorization

```hcl
module "cmk_prerequisites" {
  source = "./azure/cmk-prerequisites"

  subscription_id     = "00000000-0000-0000-0000-000000000000"
  location            = "eastus"
  resource_group_name = "my-resource-group"
  key_vault_name      = "my-keyvault"
  key_name            = "my-cmk"
}
```

### With access policies (SPN + Managed Identity)

```hcl
module "cmk_prerequisites" {
  source = "./azure/cmk-prerequisites"

  subscription_id      = "00000000-0000-0000-0000-000000000000"
  location             = "eastus"
  resource_group_name  = "my-resource-group"
  key_vault_name       = "my-keyvault"
  key_name             = "my-cmk"

  enable_access_policy = true
  spn_object_id        = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  managed_identity_id  = "/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-mi"
}
```

### Use an existing Key Vault and configure storage account CMK

```hcl
module "cmk_prerequisites" {
  source = "./azure/cmk-prerequisites"

  subscription_id     = "00000000-0000-0000-0000-000000000000"
  resource_group_name = "my-resource-group"
  key_vault_name      = "existing-keyvault"
  key_name            = "my-cmk"
  create_keyvault     = false

  enable_access_policy    = true
  spn_object_id           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  managed_identity_id     = "/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/my-mi"
  storage_account_id      = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/mystorageaccount"
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

The `azurerm` provider must be configured before calling this module (e.g. via environment variables, `az login`, or a service principal).

---

## Variables

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `subscription_id` | `string` | — | yes | Azure Subscription ID where the Key Vault resides |
| `resource_group_name` | `string` | — | yes | Resource group for the Key Vault |
| `key_vault_name` | `string` | — | yes | Name of the Key Vault (new or existing) |
| `key_name` | `string` | — | yes | Name of the CMK to create inside the Key Vault |
| `location` | `string` | `null` | conditional | Azure region for the Key Vault. Required when `create_keyvault = true` |
| `create_keyvault` | `bool` | `true` | no | Whether to create a new Key Vault. Set to `false` to reference an existing one |
| `enable_access_policy` | `bool` | `false` | no | Whether to create Key Vault access policies. When `true`, the vault is configured with Access Policy authorization instead of RBAC |
| `spn_object_id` | `string` | `null` | conditional | Object ID of the Service Principal to grant access. Required when `enable_access_policy = true` |
| `managed_identity_id` | `string` | `null` | conditional | Full resource ID of the User-Assigned Managed Identity to grant access. Required when `enable_access_policy = true` or `storage_account_id` is set |
| `storage_account_ids` | `map(string}` | `null` | no | Map of Resource ID of a Storage Account to configure with CMK encryption |
| `tags` | `map(string)` | `null` | no | Tags to apply to created resources |

### Validation rules

- `location` must be provided when `create_keyvault = true`
- `spn_object_id` must be non-empty when `enable_access_policy = true`
- `managed_identity_id` must be provided when `enable_access_policy = true`
- `managed_identity_id` must be provided when `storage_account_id` is set (Azure requires a managed identity for storage CMK encryption)
- When using an existing Key Vault (`create_keyvault = false`), it must be configured with **Access Policy** authorization, not RBAC — the module will fail a postcondition check otherwise

---

## Outputs

| Name | Description |
|------|-------------|
| `cmk_key_id` | The full resource ID of the created CMK key |
| `cmk_key_vault_id` | The resource ID of the Key Vault (created or referenced) |

---

## Resources

| Resource | Condition |
|----------|-----------|
| `azurerm_key_vault.kv` | Created when `create_keyvault = true` |
| `azurerm_key_vault_key.default` | Always created |
| `azurerm_role_assignment.caller` | Created when `create_keyvault = true`; assigns **Key Vault Crypto Officer** to the Terraform caller |
| `azurerm_key_vault_access_policy.kv` | Created when `enable_access_policy = true`; one policy each for the SPN, Managed Identity, and current caller |
| `azurerm_storage_account_customer_managed_key.cdp` | Created when `storage_account_ids` is provided |

### Access policy permissions

| Principal | Key permissions | Secret permissions |
|-----------|----------------|--------------------|
| Service Principal | List, Get, Decrypt, Encrypt, WrapKey, UnwrapKey | Set, Get, List |
| Managed Identity | List, Get, Decrypt, Encrypt, WrapKey, UnwrapKey | Set, Get, List |
| Current caller (owner) | Create, List, Delete, Get, Purge, Recover, Update, GetRotationPolicy, SetRotationPolicy | Set, Get, List |

---

## Key rotation policy

The CMK is configured with automatic rotation:

- **Expiry:** 90 days after creation (`P90D`)
- **Auto-rotate:** 30 days before expiry (`P30D`)
- **Expiry notification:** 29 days before expiry (`P29D`)

---

## Notes

- The Key Vault is created with the **Premium** SKU and purge protection enabled (7-day soft-delete retention), as required by CDP.
- When `create_keyvault = false`, the existing Key Vault **must** use Access Policy authorization. RBAC-enabled vaults are rejected at plan time via a `postcondition`.
- The `azurerm_role_assignment.caller` resource is only created for new vaults. If you bring your own vault, ensure the Terraform caller already has sufficient permissions to create keys.