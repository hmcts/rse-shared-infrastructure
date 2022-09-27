
resource "azurerm_dashboard_grafana" "dashboard-grafana" {
  name                              = "${var.product}-grafana-${var.env}"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = "westeurope"

  identity {
    type = "SystemAssigned"
  }

  tags = var.common_tags
}