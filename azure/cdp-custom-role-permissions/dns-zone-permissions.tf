variable "enable_dns_zone_subscription" {
  default = true
  type = bool
  description = "The privable DNS zone is in a subscription other than CDP subscription. "
}
variable "dns_zone_actions" {
  type = list(string)
  description = "Use `Private DNS Zone Contributor` buildin role or a custom role with these actions if the private DNS zone is in a subscription other than the CDP subscription. And grant it to the SPN or the Managed Identity. "
  default = [
      "Microsoft.Network/privateDnsZones/write",
      "Microsoft.Network/privateDnsZones/read",
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read",
      "Microsoft.Network/privateDnsZones/A/read",
      "Microsoft.Network/privateDnsZones/A/write",
      "Microsoft.Network/privateDnsZones/A/delete",
      "Microsoft.Network/privateDnsZones/join/action"
  ]
}
