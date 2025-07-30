resource "azurerm_resource_group" "prerequisite" {
  count    = var.create_resource_group ? 1:0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
data "azurerm_resource_group" "prerequisite" {
  count    = var.create_resource_group ? 0:1
  name     = var.resource_group_name
}
locals{
  resource_group_name = var.create_resource_group ? azurerm_resource_group.prerequisite[0].name : data.azurerm_resource_group.prerequisite[0].name
}
############# Storage ############
resource "azurerm_storage_account" "cdp" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = var.obj_storage_performance.account_tier
  account_replication_type = var.obj_storage_performance.replication
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  tags = var.tags
}

resource "azurerm_storage_container" "containers" {
  for_each              = var.storage_locations
  name                  = each.value
  storage_account_id    = azurerm_storage_account.cdp.id
  container_access_type = "private"
}

output "storage" {
  value = {
    storage-location = "${var.storage_locations.data}@${azurerm_storage_account.cdp.primary_dfs_host}"
    log-location     = "${var.storage_locations.logs}@${azurerm_storage_account.cdp.primary_dfs_host}"
    backup-location  = "${var.storage_locations.backups}@${azurerm_storage_account.cdp.primary_dfs_host}"
  }
}
############## Managed Identity #################
resource "azurerm_user_assigned_identity" "managed_id" {
  for_each            = var.managed_id
  location            = var.location
  name                = each.value
  resource_group_name = local.resource_group_name

  tags                = var.tags
}
resource "azurerm_user_assigned_identity" "raz" {
  count               = var.raz_mi_name == null ? 0:1
  location            = var.location
  name                = var.raz_mi_name
  resource_group_name = local.resource_group_name

  tags = var.tags
}

output "managed_identities" {
  value = {
    assumer    = azurerm_user_assigned_identity.managed_id["assumer"].id
    dataaccess = azurerm_user_assigned_identity.managed_id["dataaccess"].id
    logger     = azurerm_user_assigned_identity.managed_id["logger"].id
    ranger     = azurerm_user_assigned_identity.managed_id["ranger"].id
    raz        = var.raz_mi_name == null ? null : azurerm_user_assigned_identity.raz[0].id
  }
}
