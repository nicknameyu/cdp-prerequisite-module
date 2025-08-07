# CDP Prerequiste module.

A terraform module to create Cloudera CDP Public Cloud prerequisite resources. 

## Usuage:

### Azure
There are 5 modules in Azure directory. 
- `service-principal` module is to create service principal for CDP to communicate with a user's Azure subscription. Some users have different IAM team to manage the service principal, custom roles, and role assignment. So this one has to be independent from others. 
- `env-prerequisites` module is to create environment fundation prerequisites including storage account, managed identities, as well as the role assignments between the managed identities and the resources.
- `data-service-prerequisites` module creates a custom role and assign the custom role to the Datalake Admin managed identity. 
- `cmk-prerequisites` module creates Azure Key Vault, key, as well as access policies for SPN, the managed identity for encyption, and the runner of this module. 
- `nfs-prerequisites` module creates an NFS service on an Azure storage account, and encrypt it if necessary. 

### AWS
#### Variables
- region: Optional. AWS region to deploy the resources. Default to `us-west-2`
- cdp_bucket_name: Mandatory. AWS bucket name. 
- folders: Optional. The folders in the AWS bucket for CDP to use. Default to `data`, `logs`, `backups`.
- ssh_key: Optional. The public key will be used to create an SSH public key in the AWS account. If not provided, the ssh key will not be created. 
- cross_account_role: Mandatory. The name of the cross account role and whether it is an existing role or need to be created. 
  - if the `create_role` attribute is false, a role with this name must exist. Prerequisite resources will create necessary trust relationship with this role.
  - if the `create_role` attribute is true, a role with this name will be created, and proper permission will be granted.
- aws_sso_user_arn_keyword: Optional. This is a key word to create a trust relationship for the cross account role to the administrator. So that the administrator can assume the cross account role and conduct administrative tasks on the provisioned CDP resources like EKS. The default value is a random string to avoid everyone being able to assume the role.
- cmk: Optional. This is to indicate whether to use KMS in the provisioning. If null, no CMK will be used. If create_key is true, a key will be created, and proper key policy will be attached to the key_alias. If create_key is false, proper key policy will be attached to the key with the key_alias.
- use_raz: not yet supported. default to null.
- tags: Optional. tags to be attached to the new create resources
- role_names: Optional. The names of the custom roles for CDP to conduct its job. Default to 
```
    idbroker       = "CDP_IDBROKER"
    logger         = "CDP_LOG_ROLE"
    ranger         = "CDP_RANGER_AUDIT"
    datalake_admin = "CDP_DATALAKE_ADMIN"
```
- policy_names: Optional. The names of the policies to be used in CDP provisioning. Default to:
```
    cross_account_policy        = "cdp-cross-account-policy"
    ec2-kms-policy              = "cdp-ec2-kms-policy"
    sse-kms-read-only-policy    = "cdp-sse-kms-read-only-policy"
    sse-kms-read-write-policy   = "cdp-sse-kms-read-write-policy"
    idbroker-assume-role-policy = "cdp-idbroker-assume-role-policy"
    log-policy                  = "cdp-log-policy"
    datalake-restore-policy     = "cdp-datalake-restore-policy"
    backup-policy               = "cdp-backup-policy"
    ranger-audit-s3-policy      = "cdp-ranger-audit-s3-policy"
    bucket-access-policy        = "cdp-bucket-access-policy"
    datalake-backup-policy      = "cdp-datalake-backup-policy"
    datalake-admin-s3-policy    = "cdp-datalake-admin-s3-policy"
```
- instance_profile_names: Optional. The name of the instance profiles to be used in CDP provisioning. Default to
```
    data_access = "cdp-data-access-instance-profile"
    log_access  = "cdp-log-access-instance-profile"
```

#### Example
```
module "prerequisite" {
  source = "${Path to this repo}//aws?ref=main"
  cross_account_role = {
    name        = "cdp-poc-role"
    create_role = false
  }
  cdp_bucket_name = "cdp-poc-bucket"
  ssh_key = {
    name = "my-ssh-key"
    key = file("~/.ssh/id_rsa.pub")
  }
  cmk = {
    key_alias = "my-cdp-key"
    create_key = true
  }
  tags = {
    owner = "My Name"
  }
}

output "prerequisite" {
  value = module.prerequisite
}
```