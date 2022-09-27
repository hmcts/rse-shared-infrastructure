
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
  value = "postgresql://pgadmin:${module.database.password}@${module.database.fqdn}:5432/dashboard}?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}
