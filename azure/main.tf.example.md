```
module "az-prerequisites" {
  source = "./env-prerequisites"
  subscription_id = "######################"
  managed_id = {
    assumer = "cdp-assumer"
    dataaccess = "cdp-dataaccess"
    logger = "cdp-logger"
    ranger = "cdp-ranger"
  }
  raz_mi_name = "cdp-raz"
  storage_account_name = "<cdp storage account name>"
  resource_group_name = "<cdp resource group name>"
  location = "westus2"
}


output "storage_locations" {
  value =  module.az-prerequisites.storage
}
output "managed_id" {
  value = module.az-prerequisites.managed_identities
}

module "dw-prerequisites" {
  source = "./dw-prerequisites"
  dw_custom_role = "<DW custom role name>"
  dataaccess_mi  = module.az-prerequisites.managed_identities.dataaccess
  subscription_id = "##########################"
  create_dw_custom_role = true
}
```