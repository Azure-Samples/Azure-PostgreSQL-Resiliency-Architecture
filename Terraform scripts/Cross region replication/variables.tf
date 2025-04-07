variable "subscriptionID"{
  default = "<Enter-Your-Subscription-ID>"
}
variable "resourceName" {
  default     = "<resource-group-name>"
  description = "Prefix of the resource name."
}
variable "location" {
  default     = "<region>"
  description = "Region of the resource group."
}  
variable "virtualNetwork"{
  default ="<vnet-name>"
  description="region name for the resource"
}
variable "networkSecurityGroupName"{
  default="<nsg-name>"
  description="security group name"
}
variable "subnetName"{
  default ="<subnet-name>"
  description="subnet name"
}
variable "privateDNSZone"{
  default="<private-dns-name>.postgres.database.azure.com"
  description = "name for Private DNS Zone"
}
variable "privateDNSZoneNetworkLink"{
  default ="<private-DNS-network-link>.com"
  description="nName for DNS Zone Link"
}
variable "flexibleServeInstance"{
  default ="<flex-server-name>"
  description="name for flex server instance"
}
variable "privateEndpointName"{
  default="<private-endpoint-name>"
  description = "name for private endpoint"
}
variable "privateServiceConnection"{
  default = "<private-service-connection-name>"
  description = "name for private service connection"
}
variable "readReplica1"{
    default="<replica-server1-name>"
    description="read replica 1"
}
variable "readReplica2"{
    default="<replica-server2-name>"
    description="read replica 2"
}
variable "crossregion1"{
    default="<crossregion-replica1-name>"
    description="cross region read replica 1"
}
variable "crossregion2"{
    default="<crossregion-replica2-name>"
    description="cross region read replica 2"
}
variable "crossregion3"{
    default="<crossregion-replica3-name>"
    description="cross region read replica 3"
}
variable "username"{
    default="<username>"

}
variable "location2"{
  default="<cross-regionreplica-region>"
  description="Select a different region than primary instance"
}
variable "pgVersion"{
  default="16"
}
variable "storage"{
  default=32768
}
variable "storageTier"{
  default = "P30"
}
variable "skuName"{
  default = "GP_Standard_D2ads_v5"
}
variable "sgName"{
  default ="<service-group-name>"
}
variable "username" {
  default="<user-name>"
}
variable "password"{
  default="<password>"
}
