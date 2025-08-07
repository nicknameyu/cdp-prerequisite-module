# NFS module 

Use this modure to create Azure NFS for CAI
- Add subnets to the NFS firewall if the subnets information is provided.
- Encrypt the storage account if the encryption information is provided. 

## Example usage
```
module "nfs" {
  source               = "../azure/nfs-prerequisites"
  subscription_id      = "#########################"
  resource_group_name  = "cdp-module-rerequisiste"
  location             = "westus2"
  storage_account_name = "cdptestnfsstorage"
  file_share_name      = "testnfs"

  subnet_ids           = var.subnet_ids
}
```