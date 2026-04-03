# Azure NFS Prerequisites Module

This Terraform module provisions an Azure NFS file share for use with Cloudera Data Platform (CDP). It creates an Azure Storage Account configured for NFS (`FileStorage` kind) along with a file share, and optionally manages the associated resource group and Customer Managed Key (CMK) encryption.

## Features

- Creates an Azure Storage Account with NFS protocol support
- Creates an NFS-enabled Azure File Share
- Automatically adds the Terraform client's public IP to the storage account firewall
- Optionally creates a resource group to hold the storage resources
- Supports subnet-based firewall allowlisting (via subnet IDs or subnet names + VNet lookup)
- Supports Customer Managed Key (CMK) encryption via Azure Key Vault

---

## Usage

### Minimal example (with subnet IDs)

```hcl
module "nfs" {
  source               = "../azure/nfs-prerequisites"
  subscription_id      = "<your-subscription-id>"
  resource_group_name  = "cdp-prerequisites"
  location             = "westus2"
  storage_account_name = "cdptestnfsstorage"
  file_share_name      = "testnfs"

  subnet_ids = ["<subnet-id-1>", "<subnet-id-2>"]
}
```

### With subnet name lookup (VNet-based)

```hcl
module "nfs" {
  source               = "../azure/nfs-prerequisites"
  subscription_id      = "<your-subscription-id>"
  resource_group_name  = "cdp-prerequisites"
  location             = "westus2"
  storage_account_name = "cdptestnfsstorage"
  file_share_name      = "testnfs"

  vnet_resource_group_name = "cdp-network-rg"
  vnet_name                = "cdp-vnet"
  subnet_names             = ["cdp-subnet-1", "cdp-subnet-2"]
}
```

### With resource group creation

```hcl
module "nfs" {
  source                = "../azure/nfs-prerequisites"
  subscription_id       = "<your-subscription-id>"
  resource_group_name   = "cdp-nfs-rg"
  create_resource_group = true
  location              = "westus2"
  storage_account_name  = "cdptestnfsstorage"
  file_share_name       = "testnfs"

  subnet_ids = ["<subnet-id-1>"]
}
```

### With Customer Managed Key (CMK) encryption

```hcl
module "nfs" {
  source               = "../azure/nfs-prerequisites"
  subscription_id      = "<your-subscription-id>"
  resource_group_name  = "cdp-prerequisites"
  location             = "westus2"
  storage_account_name = "cdptestnfsstorage"
  file_share_name      = "testnfs"

  subnet_ids = ["<subnet-id-1>"]

  cmk_resources = {
    key_vault_id = "<key-vault-resource-id>"
    key_name     = "cdp-nfs-key"
    managed_id   = "<user-assigned-managed-identity-resource-id>"
  }
}
```

---

## Input Variables

### General

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `subscription_id` | `string` | Yes | — | Azure Subscription ID for the storage account. |
| `location` | `string` | Yes | — | Azure region in which to create the storage account. |
| `tags` | `map(string)` | No | `null` | Tags to apply to the storage account. |

### Resource Group

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `resource_group_name` | `string` | Yes | — | Name of the resource group to hold the storage account. |
| `create_resource_group` | `bool` | No | `false` | When `true`, a new resource group is created. When `false`, the specified resource group must already exist. |

### Storage & File Share

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `storage_account_name` | `string` | Yes | — | Name of the Azure Storage Account. Must be globally unique. |
| `file_share_name` | `string` | Yes | — | Name of the NFS file share. |
| `size` | `number` | No | `100` | Quota of the file share in GB. |
| `account_tier` | `string` | No | `"Premium"` | Storage account performance tier. NFS requires `Premium`. |
| `replication` | `string` | No | `"LRS"` | Replication type for the storage account (e.g., `LRS`, `ZRS`). |

### Network

Subnets can be specified either by providing their IDs directly (`subnet_ids`) **or** by providing the VNet details and subnet names (`vnet_resource_group_name`, `vnet_name`, `subnet_names`). These two approaches are mutually exclusive.

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `subnet_ids` | `list(string)` | No | `null` | List of subnet resource IDs to allow through the storage account firewall. |
| `vnet_resource_group_name` | `string` | No | `null` | Resource group of the VNet (used with `vnet_name` and `subnet_names`). Must be `null` if `subnet_ids` is set. |
| `vnet_name` | `string` | No | `null` | Name of the VNet (used with `vnet_resource_group_name` and `subnet_names`). Must be `null` if `subnet_ids` is set. |
| `subnet_names` | `list(string)` | No | `null` | List of subnet names to look up within the specified VNet. Must be `null` if `subnet_ids` is set. |

### Customer Managed Key (CMK)

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `cmk_resources` | `object` | No | `null` | CMK configuration object. If omitted, the storage account uses Microsoft-managed keys. See object attributes below. |

`cmk_resources` object attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `key_vault_id` | `string` | Resource ID of the Azure Key Vault containing the CMK. |
| `key_name` | `string` | Name of the key within the Key Vault. |
| `managed_id` | `string` | Resource ID of the User Assigned Managed Identity used to access the key. |

---

## Outputs

| Name | Description |
|------|-------------|
| `nfs_file_share` | NFS mount path in the format `nfs://<storage-account-host>:/<account>/<share>`. Use this value when configuring NFS mounts in CDP. |

---

## Notes

- **Firewall**: The storage account firewall is set to `Deny` by default. The public IP address of the machine running `terraform apply` is automatically added as an allowed IP. Ensure this is accounted for in restricted network environments.
- **HTTPS**: HTTPS-only traffic is disabled (`https_traffic_only_enabled = false`) to support NFS protocol, which does not use HTTPS.
- **CMK lifecycle**: The `customer_managed_key` attribute on the storage account is set to `ignore_changes` to prevent Terraform drift after initial CMK association.
- **NFS protocol**: The storage account kind is fixed to `FileStorage`, which is required for NFS file shares.

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| azurerm | >= 3.0 |
| http | >= 3.0 |