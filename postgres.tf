
locals {
  component    = "dashboard"
  outbound_ips = try(azurerm_dashboard_grafana.dashboard-grafana[0].outbound_ip, [])
}

module "postgresql" {
  count = var.dashboard_count

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
  public_access = true
  pgsql_firewall_rules = [
    for ip in local.outbound_ips : {
      name             = "grafana${index(local.outbound_ips, ip) + 1}"
      start_ip_address = ip
      end_ip_address   = ip
    }
  ]
  admin_user_object_id = var.jenkins_AAD_objectId

  common_tags = var.common_tags
}

module "postgresql-new" {
  count = var.dashboard_count

  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env    = var.env

  name          = "dtsse-dashboard-flexible"
  product       = var.product
  component     = local.component
  business_area = "cft" # sds or cft

  pgsql_databases = [
    {
      name : "dashboard"
    }
  ]

  pgsql_version = "14"

  pgsql_firewall_rules = [
    for ip in local.outbound_ips : {
      name             = "grafana${index(local.outbound_ips, ip) + 1}"
      start_ip_address = ip
      end_ip_address   = ip
    }
  ]
  admin_user_object_id = var.jenkins_AAD_objectId

  common_tags = var.common_tags
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  count     = var.dashboard_count
  name      = "azure.extensions"
  server_id = module.postgresql[0].instance_id
  value     = "hypopg,plpgsql,pg_stat_statements,pg_buffercache"
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions-new" {
  count     = var.dashboard_count
  name      = "azure.extensions"
  server_id = module.postgresql-new[0].instance_id
  value     = "hypopg,plpgsql,pg_stat_statements,pg_buffercache"
}

resource "azurerm_key_vault_secret" "DB-URL" {
  count        = var.dashboard_count
  name         = "db-url"
  value        = "postgresql://${module.postgresql[0].username}:${module.postgresql[0].password}@${module.postgresql[0].fqdn}:5432/dashboard?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_key_vault_secret" "DB-URL-new" {
  count        = var.dashboard_count
  name         = "db-url-new"
  value        = "postgresql://${module.postgresql-new[0].username}:${module.postgresql-new[0].password}@${module.postgresql-new[0].fqdn}:5432/dashboard?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}
