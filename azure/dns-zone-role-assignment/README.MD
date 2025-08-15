# DNS Zone custom role assignment
This module is to create role assignments for Service Principal and managed identity to conduct required private DNS zone operations.
This module is used only when the private DNS zones are in a subscription other than the CDP resource subscription. 

## Usage
```
module "dns_zone_role_assignment" {
    source = "...."
    providers        = {
        azurerm.dns_zone = azurerm.secondary
    }
    principal_ids    = {
        spn = "<SPN object ID>"
        mi  = "<Managed Identity Principal ID>"
    }
}
```