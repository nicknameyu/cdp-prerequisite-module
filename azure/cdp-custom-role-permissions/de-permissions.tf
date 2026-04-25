variable "de_actions" {
  type = list(string)
  description = "Custom role permission for Data Engineering."
  default = [ 
      "Microsoft.DBforMySQL/flexibleServers/read", 
      "Microsoft.DBforMySQL/flexibleServers/write", 
      "Microsoft.DBforMySQL/flexibleServers/delete",
      "Microsoft.DBforMySQL/flexibleServers/start/action",
      "Microsoft.DBforMySQL/flexibleServers/stop/action", 
      "Microsoft.DBforMySQL/flexibleServers/firewallRules/write",
      "Microsoft.DBforMySQL/flexibleServers/start/action",
      "Microsoft.DBforMySQL/flexibleServers/stop/action", 
      "Microsoft.DBforMySQL/flexibleServers/PrivateEndpointConnectionsApproval/action", 
      // Added for CDE FIC requirement
      // https://docs.cloudera.com/data-engineering/cloud/enable-data-engineering/topics/cde-adding-required-permissions-for-azure-env-credentials.html
      "Microsoft.ManagedIdentity/userAssignedIdentities/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/write",
      "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials/delete",
      ]
}
variable "enable_de" {
  type = bool
  default = true
  description = "Enable Liftie permissions. Default to true."
}
