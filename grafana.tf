
resource "azurerm_dashboard_grafana" "dashboard-grafana" {
  name                              = "${var.product}-grafana-${var.env}"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = "westeurope"
  deterministic_outbound_ip_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}

data "azuread_group" "viewers" {
  display_name = "SSO Dynatrace HMCTS Access"
}

resource "azurerm_role_assignment" "viewers" {
  scope                = azurerm_dashboard_grafana.dashboard-grafana.id
  role_definition_name = "Grafana Viewer"
  principal_id         = data.azuread_group.viewers.object_id
}

data "azuread_group" "more_viewers" {
  display_name = "SSO Dynatrace HMCTS Access"
}

resource "azurerm_role_assignment" "more_viewers" {
  scope                = azurerm_dashboard_grafana.dashboard-grafana.id
  role_definition_name = "GeoBlocking - Restricted Users"
  principal_id         = data.azuread_group.more_viewers.object_id
}

data "azuread_group" "editors" {
  display_name = "DTS CFT Developers"
}

resource "azurerm_role_assignment" "editors" {
  scope                = azurerm_dashboard_grafana.dashboard-grafana.id
  role_definition_name = "Grafana Editor"
  principal_id         = data.azuread_group.editors.object_id
}

data "azuread_group" "admins" {
  display_name = "DTS CFT Software Engineering"
}

resource "azurerm_role_assignment" "admin" {
  scope                = azurerm_dashboard_grafana.dashboard-grafana.id
  role_definition_name = "Grafana Admin"
  principal_id         = data.azuread_group.admins.object_id
}

data "azuread_group" "platops" {
  display_name     = "DTS Platform Operations"
  security_enabled = true
}

resource "azurerm_role_assignment" "platops" {
  scope                = azurerm_dashboard_grafana.dashboard-grafana.id
  role_definition_name = "Grafana Admin"
  principal_id         = data.azuread_group.platops.object_id
}

resource "azurerm_role_assignment" "app_insights_dcd_cnp_prod_access" {
  scope                = "/subscriptions/8999dec3-0104-4a27-94ee-6588559729d1"
  role_definition_name = "Reader"
  principal_id         = azurerm_dashboard_grafana.dashboard-grafana.identity[0].principal_id
}

