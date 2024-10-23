provider "azurerm" {
  features {}
  subscription_id = "<subscriptionid>"
}
resource "azurerm_network_security_group" "example" {
  name                = "west-security-group"
  location            = "Central US"
  resource_group_name = "gkasar-readreplica-terraform"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_virtual_network" "default" {
  name                = "vn-west"
  location            = "Central US"
  resource_group_name = "gkasar-readreplica-terraform"
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_private_dns_zone" "default" {
  name                = "crossregion.postgres.database.azure.com"
  resource_group_name = "gkasar-readreplica-terraform"
}


resource "azurerm_subnet" "default" {
  name                 = "crossregion-west"
  resource_group_name  = "gkasar-readreplica-terraform"
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
  depends_on            = [azurerm_virtual_network.default]
}
resource "azurerm_postgresql_flexible_server" "crossregion1" {
  name                          = "firstreplica"
  resource_group_name           ="gkasar-readreplica-terraform"
  location                      = "Central US"
  create_mode                   = "Replica"
  source_server_id              = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.DBforPostgreSQL/flexibleServers/example"
  version                       = "16"
  public_network_access_enabled = false
  storage_mb                    = 32768
  storage_tier                  = "P30"

  sku_name = "GP_Standard_D2ads_v5"
  delegated_subnet_id           = azurerm_subnet.default.id
  private_dns_zone_id           = azurerm_private_dns_zone.default.id

}
resource "azurerm_postgresql_flexible_server" "crossregion2" {
  name                          = "secondreplica"
  resource_group_name           ="gkasar-readreplica-terraform"
  location                      = "Central US"
  create_mode                   = "Replica"
  source_server_id              = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.DBforPostgreSQL/flexibleServers/example"
  version                       = "16"
  public_network_access_enabled = false
  storage_mb                    = 32768
  storage_tier                  = "P30"

  sku_name = "GP_Standard_D2ads_v5"
  delegated_subnet_id           = azurerm_subnet.default.id
  private_dns_zone_id           = azurerm_private_dns_zone.default.id
  depends_on=[azurerm_postgresql_flexible_server.crossregion1]
}
resource "azurerm_postgresql_flexible_server" "crossregion3" {
  name                          = "thirdreplica"
  resource_group_name           ="gkasar-readreplica-terraform"
  location                      = "Central US"
  create_mode                   = "Replica"
  source_server_id              = "/subscriptions/<subscriptionid>/resourceGroups/gkasar-readreplica-terraform/providers/Microsoft.DBforPostgreSQL/flexibleServers/example"
  version                       = "16"
  public_network_access_enabled = false
  storage_mb                    = 32768
  storage_tier                  = "P30"

  sku_name = "GP_Standard_D2ads_v5"
  delegated_subnet_id           = azurerm_subnet.default.id
  private_dns_zone_id           = azurerm_private_dns_zone.default.id
  depends_on=[azurerm_postgresql_flexible_server.crossregion1]
}