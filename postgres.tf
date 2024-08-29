
locals {
  component    = "dashboard"
  outbound_ips = azurerm_dashboard_grafana.dashboard-grafana[0].outbound_ip
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
    for ip in data.azurerm_dashboard_grafana.dashboard-grafana-for-ips.outbound_ips : {
      name             = "grafana${index(data.azurerm_dashboard_grafana.dashboard-grafana-for-ips.outbound_ips, ip) + 1}"
      start_ip_address = ip
      end_ip_address   = ip
    }
  ]
  admin_user_object_id = var.jenkins_AAD_objectId

  common_tags = var.common_tags
}

data "azurerm_dashboard_grafana" "dashboard-grafana-for-ips" {
  name                = "${var.product}-grafana-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name

   #  Try something crazy?!
  outbound_ips        = [ "1.2.3.4", "5.6.7.8"]

  depends_on = [
    azurerm_dashboard_grafana.dashboard-grafana
  ]
}

resource "azurerm_postgresql_flexible_server_configuration" "extensions" {
  count     = var.dashboard_count
  name      = "azure.extensions"
  server_id = module.postgresql[0].instance_id
  value     = "hypopg,plpgsql,pg_stat_statements,pg_buffercache"
}

resource "azurerm_key_vault_secret" "DB-URL" {
  count        = var.dashboard_count
  name         = "db-url"
  value        = "postgresql://${module.postgresql[0].username}:${module.postgresql[0].password}@${module.postgresql[0].fqdn}:5432/dashboard?sslmode=require"
  key_vault_id = module.key-vault.key_vault_id
}

