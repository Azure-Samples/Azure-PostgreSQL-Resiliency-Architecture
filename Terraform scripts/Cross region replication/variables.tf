variable "subscriptionID"{
  description = "subscription ID that will be used to create resources"
}
variable "resourceGroup" {
  description = "Prefix of the resource name."
}
variable "location" {
  default     = "canadacentral"
  description = "Region of the resource group."
}  
variable "virtualNetwork"{
  description="region name for the resource"
}
variable "subnetName"{
  description="subnet name"
}
variable "flexibleServeInstance"{
  description="name for Azure Database for PostgreSQL flexible server instance"
}
variable "privateEndpointName"{
  description = "name for private endpoint"
}
variable "privateServiceConnection"{
  description = "name for private service connection"
}
variable "readReplica1"{
    description="This is read replica instance in same region as the primary"
}
variable "crossregion1"{
    description="This is read replica instance in a different region than the primary instance"
}
variable "username"{
    description = "This is username for the PostgreSQL flexible server"
}
variable "location2"{
  description="This is the region for cross region read replica"
  default = "westus"
}
variable "pgVersion"{
  default="16"
  description = "This is the version of PostgreSQL"
}
variable "storage"{
  default=32768
  description = "value in MB"
}
variable "storageTier"{
  default = "P30"
}
variable "skuName"{
  default = "GP_Standard_D2ads_v5"
}

variable "password"{
  description = "Password for the PostgreSQL flexible server"
}
variable "virtualendpoint"{
  default="Virtual endpoint for primary and cross region replica"
}
