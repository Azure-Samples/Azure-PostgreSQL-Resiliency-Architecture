resource "random_pet" "name_prefix" {
  prefix = var.name_prefix
  length = 1
}


resource "azurerm_resource_group" "default" {
  name     = "gkasar-terraform"
  location = var.location
}

resource "azurerm_virtual_network" "default" {
  name                = "gkasar-vnet"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "default" {
  name                = "gkasar-nsg"
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

resource "azurerm_subnet" "default" {
  name                 = "gkasar-subnet"
  virtual_network_name = azurerm_virtual_network.default.name
  resource_group_name  = azurerm_resource_group.default.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]

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
resource "azurerm_key_vault" "example" {
  name                        = "sample-resilience-arch"
  location                    = azurerm_resource_group.default.location
  resource_group_name         = azurerm_resource_group.default.name
  tenant_id                   = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  sku_name                    = "standard"
  purge_protection_enabled    = true
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [
      azurerm_subnet.default.id
    ]
  }
}

resource "azurerm_private_endpoint" "example1" {
  name                = "flexresilience-private-endpoint"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  subnet_id           = azurerm_subnet.default.id

  private_service_connection {
    name                           = "flexresilience-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.example.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
}
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_private_dns_zone" "default" {
  name                = "gkasar-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.default.name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "gkasar-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.default.id
  resource_group_name   = azurerm_resource_group.default.name
}

resource "random_password" "pass" {
  length = 20
}
provider "azurerm" {
  subscription_id = "5c5037e5-d3f1-4e7b-b3a9-f6bf94902b30"
  tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  features {}
}
resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "gkasar-database-server"
  resource_group_name    = azurerm_resource_group.default.name
  location               = azurerm_resource_group.default.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.default.id
  private_dns_zone_id    = azurerm_private_dns_zone.default.id
  administrator_login    = "adminTerraform"
  administrator_password = "Pass@123"
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7
  geo_redundant_backup_enabled = true
  public_network_access_enabled = false
  tags = {
    environment = "Production"
  }
  high_availability {
    mode                      = "ZoneRedundant"
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}
resource "azurerm_postgresql_flexible_server_replica" "replica" {
  name                = "replica-server-terraform"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  source_server_id    = azurerm_postgresql_flexible_server.primary.id
}
  