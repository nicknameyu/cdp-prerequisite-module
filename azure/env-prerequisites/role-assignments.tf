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

##### Private DNS Zone Custom Role #########
locals {
  sleep_dependency =  var.create_dns_zone_custom_role ? azurerm_role_definition.dns_zone : null
}
resource "time_sleep" "custom_role" {
  count = var.create_dns_zone_custom_role ? 1:0
  // Adding this sleep resource to create a delay between creating the custom roles and role assignment.
  // If the dns zone custom role was created before executing this template, this delay is no longer required.
  depends_on =  [local.sleep_dependency]
  create_duration = "600s"
}
locals {
  dns_custom_role_assign_dependency = var.create_dns_zone_custom_role ?  time_sleep.custom_role[0] : null
}
resource "azurerm_role_assignment" "dns_zone" {
  # This role assignment is mandatory for the data access managed identity to manipulate the DNS record in a private DNS zone. 
  # When DataWarehouse is in-place, a DW custom role will be assigned to data access managed identity. DW custom role includes 
  # the DNS zone custom role, so this assignment is not required,
  count                 = var.dns_zone_custom_role == null ? 0:1
  principal_id          = azurerm_user_assigned_identity.managed_id["dataaccess"].principal_id
  role_definition_name  = var.dns_zone_custom_role
  scope                 = "/subscriptions/${var.subscription_id}"
  depends_on = [ local.dns_custom_role_assign_dependency ]
}