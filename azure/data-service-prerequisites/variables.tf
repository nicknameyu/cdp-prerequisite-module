variable "custom_role_name" {
  type = string
  description = "Name of DataWarehouse Custom role. Required if DataWarehouse is in the deployment. If create_dw_custom_role is false and this value is not null, this module will look for existing DataWareHouse custom role. If create_dw_custom_role is true, this module will create the DataWarehouse custom role in this name. "
  default = null
}
variable "create_custom_role" {
  type = bool
  description = "Control whether to create DW custom role"
  default = false
}
variable "subscription_id" {
  type = string
  description = "Azure subscriptino ID to be used to deploy the resources."
}
variable "managed_identity_id" {
  type = string
  description = "Data access managed identity to be granted the DW custom role."
}


######## Default permissions ##########
variable "dw_actions" {
  type = list(string)
  description = "Custom role permission for Data Warehouse. "
  default = [                   
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
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read",
      "Microsoft.Network/privateDnsZones/A/read",
      "Microsoft.Network/privateDnsZones/A/write",
      "Microsoft.Network/privateDnsZones/A/delete",
      "Microsoft.Network/privateEndpoints/write",
      "Microsoft.Network/privateEndpoints/read",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/read",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/write",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/delete",
      "Microsoft.Network/privateDnsZones/join/action"
    ]
}
variable "enable_dw" {
  type = bool
  default = true
  description = "Enable DW permissions. Default to true."
}

variable "liftie_actions" {
  type = list(string)
  description = "Custom role permission for Liftie. "
  default = [                   
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/write",
      "Microsoft.ContainerService/managedClusters/agentPools/read",
      "Microsoft.ContainerService/managedClusters/agentPools/write",
      "Microsoft.ContainerService/managedClusters/upgradeProfiles/read",
			"Microsoft.ContainerService/managedClusters/agentPools/delete",
      "Microsoft.ContainerService/managedClusters/delete",
      "Microsoft.ContainerService/managedClusters/accessProfiles/listCredential/action",
      "Microsoft.ContainerService/managedClusters/agentPools/upgradeProfiles/read",
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
      "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/*",   # added base on doc update on 04/08/2025
      "Microsoft.Insights/metrics/read",                                                   # added base on doc update on 04/08/2025
      "Microsoft.Insights/metricDefinitions/read",                                         # added base on doc update on 04/08/2025
      "Microsoft.Compute/virtualMachineScaleSets/write",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/routeTables/read",
      "Microsoft.Network/routeTables/write",
      "Microsoft.Network/routeTables/routes/read",
      "Microsoft.Network/routeTables/routes/write"
    ]
}
variable "enable_liftie" {
  type = bool
  default = true
  description = "Enable Liftie permissions. Default to true."
}
variable "de_actions" {
  type = list(string)
  description = "Custom role permission for Data Engineering."
  default = [ 
      "Microsoft.DBforMySQL/flexibleServers/read",                             // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/write",                            // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/delete",                           // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/start/action",                     // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/stop/action",                      // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/firewallRules/write",              // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/start/action",                     // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/stop/action",                      // added base on testing 03/25/2024
      "Microsoft.DBforMySQL/flexibleServers/PrivateEndpointConnectionsApproval/action", // added base on testing 03/25/2024 
      ]
}
variable "enable_de" {
  type = bool
  default = true
  description = "Enable Liftie permissions. Default to true."
}