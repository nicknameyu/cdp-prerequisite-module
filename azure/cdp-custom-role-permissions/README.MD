# CDP Custom Role Permission actions
Use this module to generate the actions requred for custom roles to be used for CDP deployment. 
The output contains 3 custom role permissions, for SPN, for Managed Identity, for private DNS Zone

## SPN Permission
When contributor permission is not allowed, user can createa custom role with this permission for service principal.

## Managed Identity Permission
Custom role for managed identity is used for Data Services. 
Technically speaking, custom role for managed identity is not madatory for data services. However, there are two reasons a managed identity has to be configured in real case:
- AKS management principal: Service principal is being used as the managed principal for AKS if a managed identity is not provide. However, the secret for a service principal has an expriation date. When the expiration date is due, user can only update the secret for AKS with an Engineer escalation. That makes managed identity a better option for the management principal of the AKS for a data service.
- CMK encryption: when CMK encryption is used, a managed identity has to be configured to access the CMK and encrypt/decrypt the data.

## Private DNS zone permission
Private DNS zone permission is only used when the private DNS zones are created in a subscription other than the CDP subscription. Users need to create a custom role with these permission actions and grant the permission to the Service Principal as well as the Managed Identity. 

## Usage
Users can use variables: `enable_cmk`, `enable_dw`, `enable_liftie`, and `enable_de` to control the combination of permissions.
- `enable_cmk_rbac`: This is to enable CMK permissions. Default to `true`. 
- `enable_dw`: This is to enable Data Warehouse. Default to `true`.
- `enable_liftie`: This is to enable all Liftie based data services including Data Engineering, Data Flow, Cloudera AI. Default to `true`.
- `enable_de`: This is to enable Data Engineering. Default to `true`.