provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "default" {
  name     = "gkasar-terraform"
  location = "Canada Central"
}
resource "azurerm_virtual_network" "example" {
  name                = "example-vn"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_virtual_network" "default" {
  name                = "vn-west"
  location            = "Canada East"
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_network_security_group" "default" {
  name                = "example-security-group"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

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
resource "azurerm_network_security_group" "example" {
  name                = "west-security-group"
  location            = "Canada East"
  resource_group_name = azurerm_resource_group.default.name

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
resource "azurerm_subnet" "example" {
  name                 = "example-sn"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.example.name
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
}
resource "azurerm_subnet" "default" {
  name                 = "crossregion-west"
  resource_group_name  = azurerm_resource_group.default.name
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
}
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.default.id
}
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.example.id
}
resource "azurerm_private_dns_zone" "example" {
  name                = "gkasar.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
  resource_group_name   = azurerm_resource_group.default.name
  depends_on            = [azurerm_subnet.example]
}
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "westVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.default.id
  resource_group_name   = azurerm_resource_group.default.name
  depends_on            = [azurerm_subnet.default]
}
resource "azurerm_postgresql_flexible_server" "default" {
  name                          = "flex-instance-server"
  resource_group_name           = azurerm_resource_group.default.name
  location                      = azurerm_resource_group.default.location
  version                       = "16"
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = "H@Sh1CoR3!"
  zone                          = ""
  high_availability {
    mode                      = "ZoneRedundant"
  }

  storage_mb                    = 32768
  storage_tier                  = "P30"
  sku_name                      = "GP_Standard_D2ads_v5"
  delegated_subnet_id           = azurerm_subnet.example.id
  private_dns_zone_id           = azurerm_private_dns_zone.example.id
  depends_on                    = [azurerm_private_dns_zone_virtual_network_link.example]
}



