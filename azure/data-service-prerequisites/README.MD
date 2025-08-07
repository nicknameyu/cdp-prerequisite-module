# Cloudera Data Warehouse prerequisites

This module is to create some role assignments for the Managed Identity in Data Services provisioning.
The reason for this role assignment is: 
- Data services require a Managed Identity to manage the Postgres DB as well as the AKS. 
- This Managed Identity needs the permission to conduct the PG DB or MySQL and AKS related operations. 

The reason for not having this permission on Datalake and DataHub level is that CDP Datalake use service principal to manage some PG DB operations and do not use AKS.

This module support using an existing custom role or creating a new custom role.

## Usage
- `subscription_id`: Azure subscription ID. The role assingment will be on the subscription level.
- `dw_custom_role`: name of the custom role.
- `create_dw_custom_role`: switch for whether to create a new custom role or use an existing custom role.
- `dataaccess_mi`: the managed identity to be used for the service.
