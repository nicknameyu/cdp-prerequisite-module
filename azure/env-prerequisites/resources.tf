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
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
resource "azurerm_storage_account" "cdp" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = var.obj_storage_performance.account_tier
  account_replication_type = var.obj_storage_performance.replication
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  dynamic "identity" {
    for_each = var.cmk_ds_mi_name != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.cmk[0].id]
    }
  }

  network_rules {
    default_action             =  (length(var.storage_ip_rules) > 0 || length(var.subnet_ids) > 0) ? "Deny" : "Allow"
    ip_rules                   = distinct(concat(var.storage_ip_rules, [chomp(data.http.myip.response_body)] ))
    virtual_network_subnet_ids = var.subnet_ids
  }

  tags = var.tags
  lifecycle {
    // the CMK key could be changed in the future.
    ignore_changes = [
      customer_managed_key
    ]
  }
}

resource "azurerm_storage_container" "containers" {
  for_each              = var.storage_locations
  name                  = each.value
  storage_account_id    = azurerm_storage_account.cdp.id
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_path" "modelregistry" {
  count              = var.enable_ai ? 1:0
  path               = "modelregistry"
  filesystem_name    = azurerm_storage_container.containers["data"].name
  storage_account_id = azurerm_storage_account.cdp.id
  resource           = "directory"
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
resource "azurerm_user_assigned_identity" "cmk" {
  count               = var.cmk_ds_mi_name == null ? 0:1
  location            = var.location
  name                = var.cmk_ds_mi_name
  resource_group_name = local.resource_group_name

  tags = var.tags
}

output "mi_ids" {
  value = {
    assumer    = azurerm_user_assigned_identity.managed_id["assumer"].id
    dataaccess = azurerm_user_assigned_identity.managed_id["dataaccess"].id
    logger     = azurerm_user_assigned_identity.managed_id["logger"].id
    ranger     = azurerm_user_assigned_identity.managed_id["ranger"].id
    raz        = var.raz_mi_name == null ? null : azurerm_user_assigned_identity.raz[0].id
    cmk_ds     = var.cmk_ds_mi_name == null ? null : azurerm_user_assigned_identity.cmk[0].id
  }
}
output "mi_principal_ids" {
  value = {
    assumer    = azurerm_user_assigned_identity.managed_id["assumer"].principal_id
    dataaccess = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
    logger     = azurerm_user_assigned_identity.managed_id["logger"].principal_id
    ranger     = azurerm_user_assigned_identity.managed_id["ranger"].principal_id
    raz        = var.raz_mi_name == null ? null : azurerm_user_assigned_identity.raz[0].principal_id
    cmk        = var.cmk_ds_mi_name == null ? null : azurerm_user_assigned_identity.cmk[0].principal_id
  }
}
output "storage_account" {
  value = {
    resource_group_name  = local.resource_group_name 
    storage_account_name = azurerm_storage_account.cdp.name
    storage_account_id   = azurerm_storage_account.cdp.id
    data_container       = var.storage_locations.data
    log_container        = var.storage_locations.logs
    backup_container     = var.storage_locations.backups
  }
}
output "storage_locations" {
  value = {
    storage_location_base = "${var.storage_locations.data}@${azurerm_storage_account.cdp.primary_dfs_host}"
    log_location          = "${var.storage_locations.logs}@${azurerm_storage_account.cdp.primary_dfs_host}"
    backup_location       = "${var.storage_locations.backups}@${azurerm_storage_account.cdp.primary_dfs_host}"
  }
}

