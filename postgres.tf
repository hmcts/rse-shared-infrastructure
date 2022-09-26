
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

resource "azurerm_key_vault_secret" "DB-URL" {
  name = "db-url"
  value = "postgresql://${module.database.user_name}:${module.database.postgresql_password}@${module.database.host_name}:${module.database.postgresql_listen_port}/${module.database.postgresql_database}"
  key_vault_id = module.key-vault.key_vault_id
}
