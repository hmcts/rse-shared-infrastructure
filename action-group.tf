data "azurerm_key_vault_secret" "alert-email" {
  key_vault_id = module.key-vault.key_vault_id
  name         = "alert-email"
}

module "alert-action-group" {
  source   = "git@github.com:hmcts/cnp-module-action-group"
  location = "global"
  env      = var.env

  resourcegroup_name     = azurerm_resource_group.rg.name
  action_group_name      = "DTSSE Alert (${var.env})"
  short_name             = "DTSSE_Alert"
  email_receiver_name    = "DTSSE Alerts And Monitoring"
  email_receiver_address = data.azurerm_key_vault_secret.alert-email.value
}

resource "azurerm_key_vault_secret" "alert_action_group_name" {
  key_vault_id = module.key-vault.key_vault_id
  name         = "alert-action-group-name"
  value        = module.alert-action-group.action_group_name
}
