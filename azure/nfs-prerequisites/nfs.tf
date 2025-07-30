# Get the public ip of this terraform client
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
# File share is for machine learning
resource "azurerm_storage_account" "fileshare" {
  count                     = var.file_storage == null ? 0:1
  name                      = var.file_storage.storage_account_name
  resource_group_name       = local.resource_group_name
  location                  = var.location
  account_tier              = var.file_storage_performance.account_tier
  account_replication_type  = var.file_storage_performance.replication
  account_kind              = "FileStorage"
  https_traffic_only_enabled = false

  network_rules {
    default_action             = "Deny"
    ip_rules                   = [ chomp(data.http.myip.response_body) ]             // Public ip of this terraform client need to be in the storage account firewall
    virtual_network_subnet_ids = var.file_storage.subnet_ids
  }

  tags = var.tags
}
resource "azurerm_storage_share" "fileshare" {
  count                = var.file_storage == null ? 0:1
  name                 = var.file_storage.file_share_name
  storage_account_id   = azurerm_storage_account.fileshare[0].id
  quota                = 101                                      // this value must be greater than 100 for premium file storage
  enabled_protocol     = "NFS"

}
output "nfs-file-share" {
  value = var.file_storage == null ? null : "nfs://${azurerm_storage_account.fileshare[0].primary_file_host}:/${var.file_storage.storage_account_name}/${azurerm_storage_share.fileshare[0].name}"
}

