data "azuread_client_config" "current" {}

resource "azuread_application" "xaccount" {
  count        = var.create_spn ? 1:0
  display_name = var.spn_app_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "xaccount" {
  count        = var.create_spn ? 1:0
  client_id    = azuread_application.xaccount[0].client_id
  owners       = [data.azuread_client_config.current.object_id]
}
resource "azuread_service_principal_password" "xaccount" {
  count                = var.create_spn ? 1:0
  service_principal_id = azuread_service_principal.xaccount[0].id
}

data "azuread_service_principal" "xaccount" {
  count        = var.create_spn ? 0:1
  display_name = var.spn_app_name
  object_id    = var.spn_object_id
}
output "service_principal" {
  value = {
    client_id = var.create_spn ? azuread_service_principal.xaccount[0].client_id : data.azuread_service_principal.xaccount[0].client_id
    object_id = var.create_spn ? azuread_service_principal.xaccount[0].object_id : data.azuread_service_principal.xaccount[0].object_id
    secret    = var.create_spn ? azuread_service_principal_password.xaccount[0].value : "Not Available"
  }
}

locals {
  spn_object_id = var.create_spn ? azuread_service_principal.xaccount[0].object_id : data.azuread_service_principal.xaccount[0].object_id
  spn_client_id = var.create_spn ? azuread_service_principal.xaccount[0].client_id : data.azuread_service_principal.xaccount[0].client_id
}