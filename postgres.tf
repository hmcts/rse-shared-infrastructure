
locals {
  component = "dashboard"
}
module "database" {
  source = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env    = var.env
  product   = var.product
  component = local.component
  project   = "cft" # sds or cft

  pgsql_databases = [
    {
      name : "dashboard"
    }
  ]

  # Set your PostgreSQL version, note AzureAD auth requires version 12 (and not 11 or 13 currently)
  pgsql_version = "12"

  common_tags = var.common_tags
}

resource "azurerm_key_vault_secret" "DB-URL" {
  name = "db-url"
  value = "postgresql://${module.database.user_name}:${module.database.postgresql_password}@${module.database.host_name}:${module.database.postgresql_listen_port}/${module.database.postgresql_database}?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}
