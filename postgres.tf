
locals {
  component    = "dashboard"
  outbound_ips = try(azurerm_dashboard_grafana.dashboard-grafana[0].outbound_ip, [])
}

module "database" {
  count              = var.dashboard_count
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
  for_each            = toset(local.outbound_ips)
  name                = "grafana${index(local.outbound_ips, each.value) + 1}"
  resource_group_name = module.database[0].resource_group_name
  server_name         = module.database[0].name
  start_ip_address    = each.value
  end_ip_address      = each.value
}

resource "azurerm_key_vault_secret" "DB-URL" {
  count        = var.dashboard_count
  name         = "db-url"
  value        = "postgresql://${module.database[0].user_name}:${module.database[0].postgresql_password}@${module.database[0].host_name}:${module.database[0].postgresql_listen_port}/${module.database[0].postgresql_database}?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}

module "postgresql" {
  count              = var.dashboard_count

  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env    = var.env

  name          = "dtsse-dashboard-flexdb"
  product       = var.product
  component     = local.component
  business_area = "cft" # sds or cft

  pgsql_databases = [
    {
      name : "dashboard"
    }
  ]

  pgsql_version = "14"

#  # The ID of the principal to be granted admin access to the database server.
#  # On Jenkins it will be injected for you automatically as jenkins_AAD_objectId.
#  # Otherwise change the below:
  admin_user_object_id = var.jenkins_AAD_objectId

  common_tags = var.common_tags
}

resource "azurerm_key_vault_secret" "FLEXIBLE-DB-URL" {
 name         = "flexible-db-url"
  value        = "postgresql://${module.postgresql[0].username}:${module.postgresql[0].password}@${module.postgresql[0].fqdn}:5432/dashboard?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}
