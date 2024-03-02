resource "azurerm_resource_group" "prerequisite" {
  count    = var.create_resource_group ? 1:0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
locals{
  depends_on_resource = var.create_resource_group ? azurerm_resource_group.prerequisite : null
}
############# Storage ############
resource "azurerm_storage_account" "cdp" {
  name                     = var.obj_storage.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.obj_storage_performance.account_tier
  account_replication_type = var.obj_storage_performance.replication
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  depends_on = [ local.depends_on_resource ]

  tags = var.tags
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset([var.obj_storage.data_container_name, var.obj_storage.logs_container_name, var.obj_storage.backups_container_name])
  name                  = each.key
  storage_account_name  = azurerm_storage_account.cdp.name
  container_access_type = "private"
}

output "storage" {
  value = {
    storage-location = "${var.obj_storage.data_container_name}@${azurerm_storage_account.cdp.primary_dfs_host}"
    log-location     = "${var.obj_storage.logs_container_name}@${azurerm_storage_account.cdp.primary_dfs_host}"
    backup-location  = "${var.obj_storage.backups_container_name}@${azurerm_storage_account.cdp.primary_dfs_host}"
  }
}
############## Managed Identity #################
resource "azurerm_user_assigned_identity" "managed_id" {
  for_each            = var.managed_id
  location            = var.location
  name                = each.value
  resource_group_name = var.resource_group_name
  depends_on          = [ local.depends_on_resource ]

  tags                = var.tags
}

data azurerm_subscription "current"{}
data "azurerm_client_config" "current" {}
locals {
  role_assignment = {
      assumer1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["assumer"].principal_id
        scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
        role  = "Managed Identity Operator"     //Managed Identity Operator role 
      },
      assumer2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["assumer"].principal_id
        scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
        role  = "Virtual Machine Contributor"     //Virtual Machine Contributor role
      },
      assumer3 = {
        principal_id = azurerm_user_assigned_identity.managed_id["assumer"].principal_id
        scope = azurerm_storage_container.containers["logs"].resource_manager_id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      dataaccess1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
        scope = azurerm_storage_container.containers["logs"].resource_manager_id
        role  = "Storage Blob Data Owner"     //Storage Blob Data Owner role
      },
      dataaccess2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
        scope = azurerm_storage_container.containers["data"].resource_manager_id
        role  = "Storage Blob Data Owner"     //Storage Blob Data Owner role
      },
      dataaccess3 = {
        principal_id = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
        scope = azurerm_storage_container.containers["backups"].resource_manager_id
        role  = "Storage Blob Data Owner"     //Storage Blob Data Owner role
      },
      logger1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["logger"].principal_id
        scope = azurerm_storage_container.containers["logs"].resource_manager_id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      logger2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["logger"].principal_id
        scope = azurerm_storage_container.containers["backups"].resource_manager_id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      ranger1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["ranger"].principal_id
        scope = azurerm_storage_container.containers["data"].resource_manager_id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      ranger2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["ranger"].principal_id
        scope = azurerm_storage_container.containers["logs"].resource_manager_id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      ranger3 = {
        principal_id = azurerm_user_assigned_identity.managed_id["ranger"].principal_id
        scope = azurerm_storage_container.containers["backups"].resource_manager_id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },

  }
}

resource "azurerm_role_assignment" "assignment" {
  for_each             = local.role_assignment
  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
  principal_id         = each.value["principal_id"]
}

output "managed_identities" {
  value = {
    assumer    = azurerm_user_assigned_identity.managed_id["assumer"].id
    dataaccess = azurerm_user_assigned_identity.managed_id["dataaccess"].id
    logger     = azurerm_user_assigned_identity.managed_id["logger"].id
    ranger     = azurerm_user_assigned_identity.managed_id["ranger"].id
    raz        = var.raz_mi_name == null ? null : azurerm_user_assigned_identity.raz[0].id
    dw         = var.dw_mi == null ? null : azurerm_user_assigned_identity.dw[0].id
  }
}