# Environement prerequisites

Use this module to create CDP prerequisites.

Resources to be created:
- Azure ADLS Storage Account.
- 3 Storage containers.
- 4 or 5 User Assingned Identities(4 standard MIs and 1 optional RAZ MI)
- Role assingments for the Managed Identities.

## Example usage
```
module "cdp-prerequisites" {
  source              = "<path to the module>"
  subscription_id     = "##################"
  managed_id          = {
                            assumer = "cdp-test-assumer"
                            dataaccess = "cdp-test-dataaccess"
                            logger = "cdp-test-logger"
                            ranger = "cdp-test-ranger"
                         }
  raz_mi_name          = "cdp-test-raz"
  storage_account_name = "cdpmoduletest"
  resource_group_name  = "cdp-module-rerequisiste"
  location             = "westus2"
}
```