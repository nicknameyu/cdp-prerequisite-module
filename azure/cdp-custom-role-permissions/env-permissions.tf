
variable "env_reduced_permission_actions" {
  type = list(string)
  description = "Custom role permission for FreeIPA/Datalake/Datahub. "
  default = [
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
      "Microsoft.Storage/storageAccounts/blobServices/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Storage/storageAccounts/fileServices/write",
      "Microsoft.Storage/storageAccounts/listkeys/action",
      "Microsoft.Storage/storageAccounts/regeneratekey/action",
      "Microsoft.Storage/storageAccounts/delete",
      "Microsoft.Storage/locations/deleteVirtualNetworkOrSubnets/action",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/subnets/write",
      "Microsoft.Network/virtualNetworks/subnets/delete",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/publicIPAddresses/write",
      "Microsoft.Network/publicIPAddresses/delete",
      "Microsoft.Network/publicIPAddresses/join/action",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Network/networkInterfaces/write",
      "Microsoft.Network/networkInterfaces/delete",
      "Microsoft.Network/networkInterfaces/join/action",
      "Microsoft.Network/networkInterfaces/ipconfigurations/read",
      "Microsoft.Network/networkSecurityGroups/read",
      "Microsoft.Network/networkSecurityGroups/write",
      "Microsoft.Network/networkSecurityGroups/delete",
      "Microsoft.Network/networkSecurityGroups/join/action",
      "Microsoft.Compute/availabilitySets/read",
      "Microsoft.Compute/availabilitySets/write",
      "Microsoft.Compute/availabilitySets/delete",
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/images/read",
      "Microsoft.Compute/images/write",
      "Microsoft.Compute/images/delete",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/write",
      "Microsoft.Compute/virtualMachines/delete",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachines/vmSizes/read",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/deployments/read",
      "Microsoft.Resources/deployments/write",
      "Microsoft.Resources/deployments/delete",
      "Microsoft.Resources/deployments/operations/read",
      "Microsoft.Resources/deployments/operationstatuses/read",
      "Microsoft.Resources/deployments/exportTemplate/action",
      "Microsoft.Resources/subscriptions/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/assign/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/PrivateEndpointConnectionsApproval/action",  // added base on testing 09/04/2024 for supporting privatelink for postgres db flexible server
      "Microsoft.DBforPostgreSQL/servers/read",
      "Microsoft.DBforPostgreSQL/servers/write",
      "Microsoft.DBforPostgreSQL/servers/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/delete",
      "Microsoft.DBforPostgreSQL/flexibleServers/start/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/stop/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/firewallRules/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/start/action",                // added base on testing 03/25/2024
      "Microsoft.DBforPostgreSQL/flexibleServers/stop/action",                 // added base on testing 03/25/2024
      "Microsoft.DBforPostgreSQL/flexibleServers/configurations/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/configurations/write",
      "Microsoft.Network/privateDnsZones/read",
      "Microsoft.Network/privateEndpoints/read",
      "Microsoft.Network/privateEndpoints/write",
      "Microsoft.Network/privateEndpoints/delete",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/read",
      "Microsoft.Network/privateEndpoints/privateDnsZoneGroups/write",
      "Microsoft.DBforPostgreSQL/servers/privateEndpointConnectionsApproval/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnectionsApproval/action",    // Added base on testing 01/10/2025
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnections/read",              // Added base on testing 01/10/2025
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnections/delete",            // Added base on testing 01/10/2025
      "Microsoft.DBforPostgreSQL/flexibleServers/privateEndpointConnections/write",             // Added base on testing 01/10/2025
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/write",
      "Microsoft.DBforPostgreSQL/flexibleServers/databases/delete",
      "Microsoft.Network/privateDnsZones/A/read",
      "Microsoft.Network/privateDnsZones/A/write",
      "Microsoft.Network/privateDnsZones/A/delete",
      "Microsoft.Network/privateDnsZones/join/action",
      "Microsoft.Network/privateDnsZones/write",
      "Microsoft.Network/privateDnsZones/delete",
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read", 
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/write",
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/delete",        
      "Microsoft.Network/virtualNetworks/join/action",
      "Microsoft.Network/loadBalancers/delete",
      "Microsoft.Network/loadBalancers/read",
      "Microsoft.Network/loadBalancers/write",
      "Microsoft.Network/loadBalancers/backendAddressPools/join/action",
      "Microsoft.Resources/deployments/cancel/action",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/write",            // Added 9/10/2024 with testing for DE service
      "Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/read",
      "Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/write" 
    ]
}
variable "env_reduced_permission_data_actions" {
  type = list(string)
  description = "Custom role data actions for FreeIPA/Datalake/Datahub. "
  default = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action"
    ]
}

