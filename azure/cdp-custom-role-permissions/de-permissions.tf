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
