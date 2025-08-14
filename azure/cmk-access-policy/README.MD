# CMK module

This module is to create CMK key and access policies for CDP provisioning. And to change the encryption setting of a storage account if a storage account ID is provided.
Users can choose to create the Key Vault or use an existing Key Vault. 
Access policies will be created for:
- The service principal: SPN need the permission to access the key to encypt/decrypt required resources.
- The managed identity: a managed identity requires the permission to access the key to encrypt/decrypt the PG DB. 
- The user who run this module. 

## Example usage
```
module "cmk" {
  source              = "../azure/cmk-prerequisites"
  resource_group_name = "cdp-module-rerequisiste"
  storage_account_id  = "<Resource ID of storage account.>"
  key_vault_name      = "cdpmoduletestkv"
  key_name            = "cdp-key"
  spn_object_id       = "###################"
  subscription_id     = "##################"
  managed_identity_id = "<id of managed identity>"
  location            = "westus2"

}
```