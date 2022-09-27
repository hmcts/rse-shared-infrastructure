
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