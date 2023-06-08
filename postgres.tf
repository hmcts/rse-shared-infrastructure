
locals {
  component = "dashboard"
}

module "database" {
  source             = "git@github.com:hmcts/cnp-module-postgres?ref=postgresql_tf"
  product            = var.product
  component          = local.component
  location           = var.location
  env                = var.env
  postgresql_user    = var.product
  database_name      = "dashboard"
  postgresql_version = 11
  common_tags        = var.common_tags
  subscription       = var.subscription
}

resource "azurerm_postgresql_firewall_rule" "grafana" {
  for_each            = toset(azurerm_dashboard_grafana.dashboard-grafana.outbound_ip)
  name                = "grafana${index(azurerm_dashboard_grafana.dashboard-grafana.outbound_ip, each.value) + 1}"
  resource_group_name = module.database.resource_group_name
  server_name         = module.database.name
  start_ip_address    = each.value
  end_ip_address      = each.value
}

resource "azurerm_key_vault_secret" "DB-URL" {
  name         = "db-url"
  value        = "postgresql://${module.database.user_name}:${module.database.postgresql_password}@${module.database.host_name}:${module.database.postgresql_listen_port}/${module.database.postgresql_database}?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}

module "postgresql" {

  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env    = var.env

  product       = var.product
  component     = local.component
  business_area = "cft" # sds or cft

  pgsql_databases = [
    {
      name : "dashboard"
    }
  ]

  pgsql_version = "14"

  # The ID of the principal to be granted admin access to the database server.
  # On Jenkins it will be injected for you automatically as jenkins_AAD_objectId.
  # Otherwise change the below:
  admin_user_object_id = var.jenkins_AAD_objectId

  common_tags = var.common_tags
}

resource "azurerm_key_vault_secret" "FLEXIBLE-DB-URL" {
  name         = "flexible-db-url"
  value        = "postgresql://${module.postgresql.user_name}:${module.postgresql.password}@${module.postgresql.fqdn}:5432/dashboard?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}
