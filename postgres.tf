
locals {
  component = "dashboard"
}

module "database" {
  source                = "git@github.com:hmcts/cnp-module-postgres?ref=postgresql_tf"
  product               = var.product
  component             = local.component
  location              = var.location
  env                   = var.env
  postgresql_user       = var.postgresql_user
  database_name         = "dashboard"
  postgresql_version    = 11
  common_tags           = var.common_tags
  subscription          = var.subscription
}

resource "azurerm_key_vault_secret" "POSTGRES-USER" {
  name = "${local.component}-POSTGRES-USER"
  value = module.database.user_name
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS" {
  name = "${local.component}-POSTGRES-PASS"
  value = module.database.postgresql_password
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_key_vault_secret" "POSTGRES_HOST" {
  name = "${local.component}-POSTGRES-HOST"
  value = module.database.host_name
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_key_vault_secret" "POSTGRES_PORT" {
  name = "${local.component}-POSTGRES-PORT"
  value = module.database.postgresql_listen_port
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_key_vault_secret" "POSTGRES_DATABASE" {
  name = "${local.component}-POSTGRES-DATABASE"
  value = module.database.postgresql_database
  key_vault_id = module.key-vault.key_vault_id
}