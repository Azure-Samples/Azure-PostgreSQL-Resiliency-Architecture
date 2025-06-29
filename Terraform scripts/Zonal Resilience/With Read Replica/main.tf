provider "azurerm" {
  features {}
  subscription_id = var.subscriptionID
}

resource "azurerm_resource_group" "default" {
  name     = var.resourceGroup
  location = var.location
}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "azurerm_virtual_network" "example" {
  name                = var.virtualNetwork
  location            = var.location
  resource_group_name = var.resourceGroup
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = var.subnetName
  resource_group_name  = var.resourceGroup
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
 
}
resource "azurerm_postgresql_flexible_server" "default" {
  name                          = var.flexibleServeInstance
  resource_group_name           = var.resourceGroup
  location                      = var.location
  version                       = var.pgVersion
  public_network_access_enabled = false
  administrator_login = var.username
  administrator_password = var.password
  high_availability {
    mode                      = "ZoneRedundant"
  }

  geo_redundant_backup_enabled = true
  storage_mb                    = var.storage
  storage_tier                  = var.storageTier
  sku_name                      = var.skuName
}
resource "azurerm_postgresql_flexible_server" "replicaserver1" {
  name                = var.readReplica1
  administrator_login = var.username
  administrator_password = var.password
  resource_group_name           = var.resourceGroup
  location                      = var.location
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.default.id
  version                       = var.pgVersion
  public_network_access_enabled = false
  storage_mb                    = var.storage
  storage_tier                  = var.storageTier
  sku_name                      = var.skuName
  depends_on = [azurerm_postgresql_flexible_server.default]
}
resource "azurerm_private_endpoint" "example" {
  name                = var.privateEndpointName
  location            = var.location
  resource_group_name = var.resourceGroup
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                              = var.privateServiceConnection
    private_connection_resource_id    = azurerm_postgresql_flexible_server.default.id
    subresource_names                 = ["postgresqlServer"]
    is_manual_connection              = false
  }

  depends_on = [azurerm_postgresql_flexible_server.default, azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver1]
}
resource "azurerm_postgresql_flexible_server_virtual_endpoint" "example1" {
  name              = var.virtualendpoint
  source_server_id  = azurerm_postgresql_flexible_server.default.id
  replica_server_id = azurerm_postgresql_flexible_server.replicaserver1.id
  type              = "ReadWrite"
  depends_on = [azurerm_postgresql_flexible_server.default, azurerm_postgresql_flexible_server.replicaserver1]
}
