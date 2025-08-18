# CMK module

## Resources created in this module
This module is to create CMK related resources. 
- The Key Vault.
- The Key. 
- Access policies, if selected. 
- CMK encryption configuration for storage account. 

## Usage
CDP supports using both RBAC and Access policy to be used in accessing CMK resources in the Key Vault. RBAC approach is not granted in this module. Access Policy is created in this module.

`create_keyvault`: Users can choose to create the Key Vault or use an existing Key Vault. `create_keyvault` is true, a key vault will be created, otherwise, the module will look for a existing key vault. Default to true.
`key_vault_name` : The name of the key vault.
`key_name` : the name of the key.
`enable_access_policy` : Whether to create access policies. Default to false, because RBAC is now preferable, approach. 
`spn_object_id`: Optional. Must be provided when `enable_access_policy` is true. This is to create access policy for the service principal.
`managed_identity_id` : Optional. Must be provided when `enable_access_policy` is true. This is to create access policy for the managed identity.
`storage_account_id` : The ID of the storage account to be configured with CMK. 

Access policies will be created for 3 principals when `enable_access_policy` is set to true.
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
  subscription_id     = "##################"
  managed_identity_id = "<id of managed identity>"
  location            = "westus2"
}
```