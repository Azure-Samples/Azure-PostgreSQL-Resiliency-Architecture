provider "azurerm" {
  features {}
  subscription_id = var.subscriptionID
}
resource "azurerm_resource_group" "default" {
  name     = var.resourceName
  location = var.location
}
resource "azurerm_virtual_network" "example" {
  name                = var.virtualNetwork
  location            = var.location
  resource_group_name = var.resourceName
  address_space       = ["10.0.0.0/16"]
}
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "azurerm_network_security_group" "default" {
  name                = var.networkSecurityGroupName
  location            = var.location
  resource_group_name = var.resourceName
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
  resource_group_name = var.resourceName
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
 
}
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.default.id
}
resource "azurerm_private_dns_zone" "example" {
  name                = var.privateDNSZone
  resource_group_name = var.resourceName
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = var.privateDNSZoneNetworkLink
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
  resource_group_name   = var.resourceName
  depends_on            = [azurerm_subnet.example]
}
resource "azurerm_postgresql_flexible_server" "default" {
  name                          = var.flexibleServeInstance
 location            = var.location
  resource_group_name = var.resourceName
  version                       = var.pgVersion
  public_network_access_enabled = false
  administrator_login = var.username
  administrator_password = random_password.password.result
  high_availability {
    mode                      = "ZoneRedundant"
  }

  storage_mb                    = var.storage
  storage_tier                  = var.storageTier
  sku_name                      = var.skuName
}
resource "azurerm_postgresql_flexible_server" "replicaserver1" {
  name                = var.readReplica1
  administrator_login = var.username
  administrator_password = var.password
  location            = var.location
  resource_group_name = var.resourceName
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.default.id
  version                       = "16"
  public_network_access_enabled = false

  zone                          = "1"
  storage_mb                    = 32768
  storage_tier                  = "P30"
  sku_name                      = "GP_Standard_D2ads_v5"
  depends_on = [azurerm_postgresql_flexible_server.default]
}
resource "azurerm_postgresql_flexible_server" "replicaserver2" {
  name                = var.readReplica2
  administrator_login = var.username
  administrator_password = var.password
  location            = var.location
  resource_group_name = var.resourceName
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.default.id
  version                       = "16"
  public_network_access_enabled = false

  zone                          = "1"
  storage_mb                    = 32768
  storage_tier                  = "P30"
  sku_name                      = "GP_Standard_D2ads_v5"
  depends_on = [azurerm_postgresql_flexible_server.default,azurerm_postgresql_flexible_server.replicaserver1]
}


resource "azurerm_postgresql_flexible_server" "crossregionreplica1" {
  name                          = var.crossregion1
  resource_group_name           = var.resourceName
  location                      = var.location2
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.default.id
  version                       = "16"
  public_network_access_enabled = false
  storage_mb                    = 32768
  storage_tier                  = "P30"
  sku_name                      = "GP_Standard_D2ads_v5"
   depends_on = [azurerm_postgresql_flexible_server.default, azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver1,azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver2]

}
resource "azurerm_postgresql_flexible_server" "crossregionreplica2" {
  name                          = var.crossregion2
  resource_group_name           = var.resourceName
  location                      = var.location2
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.default.id
  version                       = "16"
  public_network_access_enabled = false
  storage_mb                    = 32768
  storage_tier                  = "P30"
  sku_name                      = "GP_Standard_D2ads_v5"
   depends_on = [azurerm_postgresql_flexible_server.default, azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver1,azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver2,azurerm_postgresql_flexible_server.crossregionreplica1]


}
resource "azurerm_postgresql_flexible_server" "crossregionreplica3" {
  name                          = var.crossregion3
  resource_group_name           = var.resourceName
  location                      = var.location2
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.default.id
  version                       = "16"
  public_network_access_enabled = false
  storage_mb                    = 32768
  storage_tier                  = "P30"
  sku_name                      = "GP_Standard_D2ads_v5"
   depends_on = [azurerm_postgresql_flexible_server.default, azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver1,azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver2,azurerm_postgresql_flexible_server.crossregionreplica1,azurerm_postgresql_flexible_server.crossregionreplica2]

}
resource "azurerm_private_endpoint" "example" {
  name                = var.privateEndpointName
  location            = var.location
  resource_group_name = var.resourceName
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                              = var.privateServiceConnection
    private_connection_resource_id    = azurerm_postgresql_flexible_server.default.id
    subresource_names                 = ["postgresqlServer"]
    is_manual_connection              = false
  }

  depends_on = [azurerm_postgresql_flexible_server.default, azurerm_subnet.example,azurerm_postgresql_flexible_server.replicaserver1, azurerm_postgresql_flexible_server.crossregionreplica1,azurerm_postgresql_flexible_server.crossregionreplica2,azurerm_postgresql_flexible_server.crossregionreplica3]
}
resource "azurerm_postgresql_flexible_server_virtual_endpoint" "example1" {
  name              = var.virtualendpoint
  source_server_id  = var.flexibleServeInstance
  replica_server_id = var.crossregion1
  type              = "ReadWrite"
  depends_on = [azurerm_postgresql_flexible_server.default, azurerm_postgresql_flexible_server.crossregionreplica1]

}
