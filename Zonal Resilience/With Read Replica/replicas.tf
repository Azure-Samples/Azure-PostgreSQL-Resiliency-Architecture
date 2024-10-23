provider "azurerm" {
  features {}
  subscription_id = "<subscriptionid>"
}
resource "azurerm_postgresql_flexible_server" "first" {
  name                          = "first-instance"
  resource_group_name           ="gkasar-readreplica-terraform"
  location                      = "Canada Central"
  create_mode                   = "Replica"
  source_server_id              = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.DBforPostgreSQL/flexibleServers/example"
  version                       = "16"
  public_network_access_enabled = false
  zone                          = "1"
  storage_mb                    = 32768
  storage_tier                  = "P30"

  sku_name = "GP_Standard_D2ads_v5"
    delegated_subnet_id           = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.Network/virtualNetworks/demo-vn/subnets/demo-sn"
  private_dns_zone_id           = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.Network/privateDnsZones/gkasar.postgres.database.azure.com"
}
resource "azurerm_postgresql_flexible_server" "second" {
  name                          = "second-instance"
  resource_group_name           ="gkasar-readreplica-terraform"
  location                      = "Canada Central"
  create_mode                   = "Replica"
  source_server_id              = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.DBforPostgreSQL/flexibleServers/example"
  version                       = "16"
  public_network_access_enabled = false
  zone                          = "1"
  storage_mb                    = 32768
  storage_tier                  = "P30"

  sku_name = "GP_Standard_D2ads_v5"
    delegated_subnet_id           = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.Network/virtualNetworks/demo-vn/subnets/demo-sn"
  private_dns_zone_id           = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.Network/privateDnsZones/gkasar.postgres.database.azure.com"
  depends_on = [azurerm_postgresql_flexible_server.first]
}
