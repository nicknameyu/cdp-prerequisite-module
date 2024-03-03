# CDP Prerequiste module.

A terraform module to create Cloudera CDP Public Cloud prerequisite resources. 

## Usuage:

### Azure
```
module "cdp-prerequisite" {
  source = "${Path to this repo}//azure?ref=main"
  create_resource_group = false                         # Optional. Default to true.
  resource_group_name = "prerequisite-test"             # Mandatory. 
  managed_id = {                                        # Mandatory
    assumer    = "cdp-assumer"
    dataaccess = "cdp-dataaccess"
    logger     = "cdp-logger"
    ranger     = "cdp-ranger"
  }

  tags = {                                             # Optional. Default to null
    owner = "cdp user"
    usecase = "testing"
  }

  obj_storage = {                                      # Mandatory
    storage_account_name   = "cdpstorage"
    data_container_name    = "data"
    logs_container_name    = "logs"
    backups_container_name = "backups"
  }
  file_storage = {                                     # Optional. For ML only.
    storage_account_name = "cdpfilestorage"
    file_share_name      = "ml-fileshare"
    subnet_ids           = [
      data.azurerm_subnet.default.id,
      data.azurerm_subnet.snet1.id
    ]
  }

  cmk = {                                             # Optional
    kv_name = "dyucdpkeyvault"
    key_name = "cdpkey"
    spn_object_id = "a37a577a-4502-4c7d-b6d7-8c717ee6e561"
  }
  raz_mi_name = "dyu-cdp-raz"                         # optional
  dw_mi       = {                                     # Optional
    managed_identiy_name = "cdp-dw-identity"
    custom_role_name     = "CDP DW Role"
  }
}
```