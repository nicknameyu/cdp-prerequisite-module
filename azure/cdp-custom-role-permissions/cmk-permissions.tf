variable "enable_cmk" {
  type = bool
  default = true
  description = "Enable CMK permission for RBAC. Default to true."
}
variable "cmk_rbac_actions" {
  type = list(string)
  description = "Custom role permission for CMK."
  default = [
      "Microsoft.KeyVault/vaults/read",
      "Microsoft.KeyVault/vaults/write",
      "Microsoft.KeyVault/vaults/secrets/write",
      "Microsoft.KeyVault/vaults/secrets/read",
      "Microsoft.KeyVault/vaults/keys/write",
      "Microsoft.KeyVault/vaults/keys/read",
      "Microsoft.KeyVault/vaults/deploy/action",
      "Microsoft.Compute/diskEncryptionSets/read",
      "Microsoft.Compute/diskEncryptionSets/write",
      "Microsoft.Compute/diskEncryptionSets/delete",
      "Microsoft.KeyVault/vaults/accessPolicies/write"
    ]
}
variable "cmk_rbac_data_actions" {
  type = list(string)
  description = "Custom role data permission for CMK."
  default = [
      "Microsoft.KeyVault/vaults/keys/read", 
      "Microsoft.KeyVault/vaults/keys/wrap/action", 
      "Microsoft.KeyVault/vaults/keys/unwrap/action"
    ]
}