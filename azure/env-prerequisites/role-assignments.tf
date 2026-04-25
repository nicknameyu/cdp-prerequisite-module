##### Environment role assignment ######
locals {
  role_assignment = {
      assumer1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["assumer"].principal_id
        scope = "/subscriptions/${var.subscription_id}"
        role  = "Managed Identity Operator"     //Managed Identity Operator role 
      },
      assumer2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["assumer"].principal_id
        scope = "/subscriptions/${var.subscription_id}"
        role  = "Virtual Machine Contributor"     //Virtual Machine Contributor role
      },
      assumer3 = {
        principal_id = azurerm_user_assigned_identity.managed_id["assumer"].principal_id
        scope = azurerm_storage_container.containers["logs"].id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      dataaccess1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
        scope = azurerm_storage_container.containers["logs"].id
        role  = "Storage Blob Data Owner"     //Storage Blob Data Owner role
      },
      dataaccess2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
        scope = azurerm_storage_container.containers["data"].id
        role  = "Storage Blob Data Owner"     //Storage Blob Data Owner role
      },
      dataaccess3 = {
        principal_id = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
        scope = azurerm_storage_container.containers["backups"].id
        role  = "Storage Blob Data Owner"     //Storage Blob Data Owner role
      },
      logger1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["logger"].principal_id
        scope = azurerm_storage_container.containers["logs"].id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      logger2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["logger"].principal_id
        scope = azurerm_storage_container.containers["backups"].id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      ranger1 = {
        principal_id = azurerm_user_assigned_identity.managed_id["ranger"].principal_id
        scope = azurerm_storage_container.containers["data"].id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      ranger2 = {
        principal_id = azurerm_user_assigned_identity.managed_id["ranger"].principal_id
        scope = azurerm_storage_container.containers["logs"].id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
      ranger3 = {
        principal_id = azurerm_user_assigned_identity.managed_id["ranger"].principal_id
        scope = azurerm_storage_container.containers["backups"].id
        role  = "Storage Blob Data Contributor"     //Storage Blob Data Contributor role
      },
  }
  // issue #28, CAI registry permission update
  cai_assignments = !var.enable_ai ? {} : {
    logger1 = {
      principal_id = azurerm_user_assigned_identity.managed_id["logger"].principal_id
      scope = azurerm_storage_account.cdp.id
      role  = "Storage Account Contributor"
    },
    logger2 = {
      principal_id = azurerm_user_assigned_identity.managed_id["logger"].principal_id
      scope = azurerm_storage_container.containers["data"].id
      role  = "Storage Blob Data Contributor"
    }
  }
}
resource "azurerm_role_assignment" "cai" {
  for_each             = local.cai_assignments
  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
  principal_id         = each.value["principal_id"]
}
resource "azurerm_role_assignment" "assignment" {
  for_each             = local.role_assignment
  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
  principal_id         = each.value["principal_id"]
}

############## RAZ role Assignment ###########
locals {
  raz_role_assingment = var.raz_mi_name == null ? null : {
    raz1 = {
      principal_id = azurerm_user_assigned_identity.raz[0].principal_id
      scope = azurerm_storage_account.cdp.id
      role  = "Storage Blob Data Owner"
    },
    raz2 = {
      principal_id = azurerm_user_assigned_identity.raz[0].principal_id
      scope = azurerm_storage_account.cdp.id
      role  = "Storage Blob Delegator"
    },
  }
}
resource "azurerm_role_assignment" "raz" {
  for_each             = local.raz_role_assingment
  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
  principal_id         = each.value["principal_id"]
}

############## DE MI role Assignment ###########
resource "azurerm_role_assignment" "cde" {
  // Service and cluster MIs need Storage Blob Data Contributor on Logger container
  for_each             = azurerm_user_assigned_identity.de_managed_identities
  scope                = azurerm_storage_container.containers["logs"].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value.principal_id
}
resource "azurerm_role_assignment" "cde_nfs" {
  // CMK-data service MI needs "Storage Account Contributor" on the CDE NFS
  count                = var.enable_de && var.create_nfs && var.cmk_ds_mi_name != null ? 1:0
  scope                = azurerm_storage_account.nfs[0].id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.cmk[0].principal_id
}