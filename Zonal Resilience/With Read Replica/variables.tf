variable "subscriptionID"{
  default = "<Enter-Your-Subscription-ID>"
}
variable "resourceName" {
  default     = <resource-group-name>"
  description = "Prefix of the resource name."
}

variable "location" {
  default     = "<region>"
  description = "Location of the resource."
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
variable "location2"{
  default="<cross-regionreplica-region>"
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
