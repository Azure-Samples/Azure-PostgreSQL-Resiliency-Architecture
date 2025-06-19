variable "subscriptionID"{
  default = "<Enter-Your-Subscription-ID>"
}
variable "resourceGroup" {
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
variable "subnetName"{
  default ="<subnet-name>"
  description="subnet name"
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
variable "username"{
    default="<username>"

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
