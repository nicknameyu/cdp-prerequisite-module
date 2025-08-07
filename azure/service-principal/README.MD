# CDP Credential module

This module is not to create a CDP credential. Instead, this module is to create Azure Service Principal and role assignment to SPN so that a CDP crednetial can be created on Cloudera UI.

## Service Principal
This module can be used to create the Service Principal and grant required permission, or grant permission to an existing Service Principal.
- To create the service principal: set `create_spn` to `true` and provide `spn_app_name`.
- To grant permission to an existing service principal, provide `spn_app_name` or `spn_object_id`

## Role Assingment
- This module can be used to grant permission to a new created service principal or an existing service principal. 
- The role assignment scope is the subscription. 
- This module can be used to create a custom role or use an existing role for the service principal. 
  - By default, the `Contributor` role will be granted. 
  - If `create_custom_role` is set to true, a custom role with name `custom_role_name` will be created.

### Custom role permission
Custom role permitted actions are reduced permissions decided by input. 
By default, a combination of reduced permissions for CDP Datahub, CMK, Data Warehouse, Liftie, Data Engineering. Users can switch off each of the premission groups by set `enable_dw`, `enable_cmk`, `enable_liftie`, or `enable_de` to `false`.

## Example usage
```
module "credential" {
  source = "../azure/service-principal"
  subscription_id = "######################"
  tenant_id = "#######################"
  spn_app_name = "dyu-terraform-poc"
  create_spn = true
  
  # custom_role_name = "CDP Custom role"
  # create_custom_role = true
}
```