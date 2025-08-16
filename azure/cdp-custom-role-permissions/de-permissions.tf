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
      ]
}
variable "enable_de" {
  type = bool
  default = true
  description = "Enable Liftie permissions. Default to true."
}
