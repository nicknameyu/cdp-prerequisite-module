#### custom role for Private DNS Zones ###
resource "azurerm_role_definition" "dns_zone" {
  count       = var.create_dns_zone_custom_role ? 1:0
  name        = var.dns_zone_custom_role
  scope       = var.subscription_id
  description = "Custom role for private DNS zone operation"
  permissions {
    actions     = [                   
      "Microsoft.Network/privateDnsZones/A/read",
      "Microsoft.Network/privateDnsZones/A/write",
      "Microsoft.Network/privateDnsZones/A/delete",
      "Microsoft.Network/privateDnsZones/virtualNetworkLinks/read",
      "Microsoft.Network/privateDnsZones/read",
      "Microsoft.Network/privateDnsZones/write"
    ]
  }
  assignable_scopes = [
    "/subscriptions/${var.subscription_id}"
  ]
}
