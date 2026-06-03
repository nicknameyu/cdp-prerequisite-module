# storage encryption

Terraform module that applies **Customer-Managed Key (CMK) encryption** to one or more Azure Storage Accounts using an Azure Key Vault key and a User-Assigned Managed Identity.

## Design idea
### why the storage encryption must be an independent module
**Considerations:**
- The CMK and key vault are created in the [cmk-prerequisites](../cmk-prerequisites/) module. In real customer practice, this is usually created by Cloud Admin team independently from DataScience team.
- The encryption MI is created in the [env-prerequisites](../env-prerequisites/) module. 
- The RBAC for the MI is granted in the [service-principal](../service-principal/) module, because the MI and the SPN need to share the same permissions for several different resources.

**Design Challenges:**
- The storage encryption cannot be done in `cmk-prerequisites` module, because `cmk-prerequisites` module is supposed to be independent. 
- The storage encryption cannot be done in `env-prerequisites` module, because the RBAC has not been done yet.
- The storage encryption cannot be done in `service-principal` module, because it doesn't align with the purpose of `service-principal` module.

### Is it worth while to have such a simple module?
The entire repo gives the users a impression that it is designed to complete all the prerequisites settings. If this module is not provided, the users will easily miss this piece in the practice.


---

## Usage

```hcl
module "storage_cmk" {
  source = "./modules/storage-encryption"

  storage_account_ids = {
    cdp = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/primary"
    nfs = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/secondary"
  }

  key_vault_key_id    = azurerm_key_vault_key.cmk.id
  managed_identity_id = azurerm_user_assigned_identity.storage.id
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azurerm | >= 3.0.0 |

---

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account_customer_managed_key.cdp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |

---

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `storage_account_ids` | A map of logical names to Storage Account resource IDs to be encrypted. | `map(string)` | yes |
| `key_vault_key_id` | The ID of the Azure Key Vault Key used for encryption. | `string` | yes |
| `managed_identity_id` | The resource ID of the User-Assigned Managed Identity used for Key Vault access. | `string` | yes |

---

## Prerequisites

The following must be in place **before** applying this module:

1. **Key Vault access policy / RBAC** — the User-Assigned Managed Identity must have at least `Key Vault Crypto Service Encryption User` permissions (RBAC) or an access policy granting `get`, `wrapKey`, and `unwrapKey` on the target Key Vault.

2. **Storage Account identity assignment** — each Storage Account must have the User-Assigned Managed Identity associated with it before this module runs. This is typically done via `identity { type = "UserAssigned"; identity_ids = [...] }` on the `azurerm_storage_account` resource.

3. **Soft-delete & purge protection** — the Key Vault must have both soft-delete and purge protection enabled, which is an Azure requirement for CMK-encrypted storage.

---

## Notes

- The module uses `for_each` over the `storage_account_ids` map, so each entry is managed as an independent resource. Adding or removing entries will only affect the corresponding storage account.
- Destroying this module will remove the CMK association and revert the storage accounts to Microsoft-managed keys (MMK); **it will not delete the storage accounts themselves**.
- Key rotation is handled automatically by Azure when the Key Vault key is rotated, provided the key version is omitted from `key_vault_key_id` (i.e., use the versionless key URI).
