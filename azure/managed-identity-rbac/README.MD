# Cloudera Data Warehouse prerequisites

This module is to create some role assignments for the Managed Identity in Data Services provisioning and CMK related provisionings.
The reason for this role assignment is: 
- Data services require a Managed Identity to manage the Postgres DB as well as the AKS. 
- This Managed Identity needs the permission to conduct the PG DB or MySQL and AKS related operations. 

The reason for not having this permission on Datalake and DataHub level is that CDP Datalake use service principal to manage some PG DB operations and do not use AKS.

This module support using an existing custom role or creating a new custom role.

## Usage
- `subscription_id`: Azure subscription ID. The role assingment will be on the subscription level.
- `custom_role_name`: name of the custom role.
- `create_custom_role`: switch for whether to create a new custom role or use an existing custom role.
- `managed_identity_id`: the managed identity to be used for the service.
- `enable_cmk_rbac`: This is to enable CMK permissions. Default to `true`. 
- `enable_dw`: This is to enable Data Warehouse. Default to `true`.
- `enable_liftie`: This is to enable all Liftie based data services including Data Engineering, Data Flow, Cloudera AI. Default to `true`.
