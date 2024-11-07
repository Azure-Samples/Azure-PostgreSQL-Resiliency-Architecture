provider "azurerm" {
  features {}
  subscription_id = var.subscriptionID
}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "azurerm_resource_group" "default" {
  name     = var.resourceName
  location = var.location
}
resource "azurerm_virtual_network" "example" {
  name                = var.virtualNetwork
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "default" {
  name                = var.networkSecurityGroupName
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  security_rule {
    name                       = var.sgName
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

resource "azurerm_subnet" "example" {
  name                 = var.subnetName
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]

}
resource "azurerm_postgresql_flexible_server" "default" {
  name                          = var.flexibleServeInstance
  resource_group_name           = azurerm_resource_group.default.name
  location                      = azurerm_resource_group.default.location
  version                       = var.pgVersion
  public_network_access_enabled = true
  administrator_login = var.username
  administrator_password = random_password.password.result
  high_availability {
    mode                      = "ZoneRedundant"
  }

  storage_mb                    = var.storage
  storage_tier                  = var.storageTier
  sku_name                      = var.skuName

}
resource "azurerm_private_endpoint" "example" {
  name                = var.privateEndpointName
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                              = var.privateServiceConnection
    private_connection_resource_id    = azurerm_postgresql_flexible_server.default.id
    subresource_names                 = ["postgresqlServer"]
    is_manual_connection              = false
  }

}
