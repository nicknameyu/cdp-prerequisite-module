# Get the public ip of this terraform client
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
resource "azurerm_resource_group" "nfs" {
  count    = var.create_resource_group ? 1:0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
# File share is for machine learning

data "azurerm_subnet" "cdp" {
  for_each             = toset(var.subnet_names == null ? [] : var.subnet_names)
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  name                 = each.value
}
locals {
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : (var.vnet_name == null ? []: [for s in data.azurerm_subnet.cdp : s.id])
}

resource "azurerm_storage_account" "nfs" {
  name                       = var.storage_account_name
  resource_group_name        = var.create_resource_group ? azurerm_resource_group.nfs[0].name : var.resource_group_name
  location                   = var.location
  account_tier               = var.account_tier
  account_replication_type   = var.replication
  account_kind               = "FileStorage"
  https_traffic_only_enabled = false

  identity {
    // This part is to prepare the possibility that an environment may need CMK to encrypt the storage account. 
    type = var.cmk_resources == null ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.cmk_resources == null ? [] : [ var.cmk_resources.managed_id ]
  }
  network_rules {
    default_action             = "Deny"
    ip_rules                   = [ chomp(data.http.myip.response_body) ]             // Public ip of this terraform client need to be in the storage account firewall
    virtual_network_subnet_ids = local.subnet_ids
  }

  tags = var.tags
  lifecycle {
    ignore_changes = [ customer_managed_key ]
  }
}
resource "azurerm_storage_share" "nfs" {
  name                 = var.file_share_name
  storage_account_id   = azurerm_storage_account.nfs.id
  quota                = var.size 
  enabled_protocol     = "NFS"
}


resource "azurerm_storage_account_customer_managed_key" "nfs" {
  count                     = var.cmk_resources == null ? 0 : 1
  storage_account_id        = azurerm_storage_account.nfs.id
  key_vault_id              = var.cmk_resources.key_vault_id
  key_name                  = var.cmk_resources.key_name
  user_assigned_identity_id = var.cmk_resources.managed_id
}
output "nfs_file_share" {
  value = "nfs://${azurerm_storage_account.nfs.primary_file_host}:/${var.storage_account_name}/${azurerm_storage_share.nfs.name}"
}

