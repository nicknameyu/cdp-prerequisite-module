
resource "azurerm_user_assigned_identity" "raz" {
  count               = var.raz_mi_name == null ? 0:1
  location            = var.location
  name                = var.raz_mi_name
  resource_group_name = var.resource_group_name
  depends_on          = [ local.depends_on_resource ]

  tags = var.tags
}
resource "azurerm_user_assigned_identity" "dw" {
  count               = var.dw_mi == null ? 0:1
  location            = var.location
  name                = var.dw_mi.managed_identiy_name
  resource_group_name = var.resource_group_name
  depends_on          = [ local.depends_on_resource ] 

  tags = var.tags
}

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
  dw_role_assignment = var.dw_mi == null ? null : {
    dw1  = {
      principal_id = azurerm_user_assigned_identity.dw[0].principal_id
      scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
      role  = azurerm_role_definition.dw[0].name
    },
    dw2 = {                                                                                     // Attention: this one is not listed in document, but it is necessary
      principal_id = azurerm_user_assigned_identity.dw[0].principal_id
      scope = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
      role  = "Managed Identity Operator"
    }
  }
}
resource "azurerm_role_assignment" "dw_and_raz" {
  for_each             = merge(local.dw_role_assignment, local.raz_role_assingment)
  scope                = each.value["scope"]
  role_definition_name = each.value["role"]
  principal_id         = each.value["principal_id"]
}

# Get the public ip of this terraform client
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
# File share is for machine learning
resource "azurerm_storage_account" "fileshare" {
  count                     = var.file_storage == null ? 0:1
  name                      = var.file_storage.storage_account_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = var.file_storage_performance.account_tier
  account_replication_type  = var.file_storage_performance.replication
  account_kind              = "FileStorage"
  enable_https_traffic_only = false
  depends_on                = [ local.depends_on_resource ]

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
  storage_account_name = azurerm_storage_account.fileshare[0].name
  quota                = 101                                      // this value must be greater than 100 for premium file storage
  enabled_protocol     = "NFS"

}
output "nfs-file-share" {
  value = var.file_storage == null ? null : "nfs://${azurerm_storage_account.fileshare[0].primary_file_host}:/${var.file_storage.storage_account_name}/${azurerm_storage_share.fileshare[0].name}"
}


#### custom role for Data Warehouse ###
resource "azurerm_role_definition" "dw" {
  count       = var.dw_mi == null ? 0:1
  name        = var.dw_mi.custom_role_name
  scope       = data.azurerm_subscription.current.id
  description = "Custom role for Cloudera Data Warehouse"

  permissions {
    actions     = [                   
      "Microsoft.Resources/deployments/cancel/action",
      "Microsoft.Resources/deployments/validate/action",
      "Microsoft.ContainerService/managedClusters/write",
      "Microsoft.ContainerService/managedClusters/agentPools/write",
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/agentPools/read",
      "Microsoft.ContainerService/managedClusters/accessProfiles/listCredential/action",
      "Microsoft.ContainerService/managedClusters/delete",
      "Microsoft.ContainerService/managedClusters/rotateClusterCertificates/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/configurations/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/configurations/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/delete",
      "Microsoft.DBforPostgreSQL/servers/virtualNetworkRules/write",
      "Microsoft.DBforPostgreSQL/servers/databases/write",
      "Microsoft.Network/privateDnsZones/A/read",
      "Microsoft.Network/privateDnsZones/A/write",
      "Microsoft.Network/privateDnsZones/A/delete",
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read",
      "Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action",
      "Microsoft.Network/virtualNetworks/subnets/read",                                 // added with testing result 07/20/2023
      "Microsoft.Network/virtualNetworks/subnets/join/action",                          // added with testing result 07/20/2023
      "Microsoft.Network/loadBalancers/write",                                          // added with testing result 07/20/2023
      "Microsoft.Network/routeTables/read",
      "Microsoft.Network/routeTables/write",
      "Microsoft.Network/routeTables/routes/read",
      "Microsoft.Network/routeTables/routes/write",
      "Microsoft.Network/routeTables/join/action",
      "Microsoft.Network/natGateways/join/action",
      "Microsoft.Network/virtualNetworks/subnets/joinLoadBalancer/action",
      "Microsoft.Network/privateDnsZones/write",
      "Microsoft.Network/privateDnsZones/read",
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/write",
      "Microsoft.Network/privateEndpoints/write",
      "Microsoft.Network/privateEndpoints/read",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/read",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/write",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/delete",
      "Microsoft.Network/privateDnsZones/join/action"
    ]

  }

  assignable_scopes = [
    data.azurerm_subscription.current.id, # /subscriptions/00000000-0000-0000-0000-000000000000
  ]
}

resource "azurerm_key_vault" "kv" {
  count                      = var.cmk == null ? 0:1
  name                       = var.cmk.kv_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_subscription.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_subscription.current.tenant_id
    object_id = var.cmk.spn_object_id

    key_permissions = [
      "List",
      "Get",
    ]

    secret_permissions = [
      "Set",
    ]
  }
  access_policy {
    tenant_id = data.azurerm_subscription.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "List",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]

    secret_permissions = [
      "Set",
    ]
  }
  lifecycle {
    ignore_changes = [ access_policy ]
  }
  
}

resource "azurerm_key_vault_key" "default" {
  count        = var.cmk == null ? 0:1
  name         = "cdp-default-key"
  key_vault_id = azurerm_key_vault.kv[0].id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

output "cmk_key_id" {
  value = var.cmk == null ? null : azurerm_key_vault_key.default[0].id
}