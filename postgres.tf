
locals {
  component = "dashboard"
}

module "database" {
  source                = "git@github.com:hmcts/cnp-module-postgres?ref=postgresql_tf"
  product               = var.product
  component             = local.component
  location              = var.location
  env                   = var.env
  postgresql_user       = var.product
  database_name         = "dashboard"
  postgresql_version    = 11
  common_tags           = var.common_tags
  subscription          = var.subscription
}

resource "azurerm_postgresql_firewall_rule" "example" {
  name                = "grafana"
  resource_group_name = module.database.resource_group_name
  server_name         = module.database.name
  start_ip_address    = azurerm_dashboard_grafana.dashboard-grafana.outbound_ip[0]
  end_ip_address      = azurerm_dashboard_grafana.dashboard-grafana.outbound_ip[0]
}

resource "azurerm_key_vault_secret" "DB-URL" {
  name = "db-url"
  value = "postgresql://${module.database.user_name}:${module.database.postgresql_password}@${module.database.host_name}:${module.database.postgresql_listen_port}/${module.database.postgresql_database}?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}
