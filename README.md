# Azure Database for PostgreSQL Resiliency Solution Accelerator
This is a solution accelerator is designed to help you explore different options that we provide with Azure Database for PostgreSQL Flexible Server Resiliency architecture, that provides you with the capability to protect data and minimize downtime for mission-critical databases during both planned and unplanned events. We are also providing ARM template and Terraform scripts in this guide that can help you get started with deploying these architectures right away. \
**Business Continuity with Flexible Server** \
Azure Database for Postgres Flexible Server is designed to protect data and minimize downtime for mission-critical databases during both planned and unplanned events. Built on the resilient Azure infrastructure, flexible server incorporates features that ensure high availability and fault tolerance. These features are essential for maintaining business continuity and include fault-protection mechanisms, rapid recovery capabilities, and measures to minimize data loss. 
When architecting applications, it is crucial to consider the following objectives to ensure business continuity:  
**1. Recovery Time Objective (RTO):** \
  This refers to the maximum acceptable amount of time an application can be offline. Different applications have varying tolerance levels for downtime; for instance, a business-critical database demands much stricter uptime compared to a test database.  
**2. Recovery Point Objective (RPO):** \
  This indicates the maximum acceptable amount of data loss measured in time. It is vital to assess how much data loss your business can tolerate in case of a disruption. 


**Geo-Redundant Backup and Restore** \
Geo-redundant backup and restore allow you to restore your server in a different region in case of a disaster, providing 16 nines of durability for backup objects over a year. This serves as a cost-effective disaster recovery solution. Customers benefit from not having to pay for computing and disaster recovery until they initiate a restore. This feature must be configured at server creation, and it asynchronously copies backup data and transaction logs to the paired region. 

**Read Replicas** \
Its important performance feature in [Product] and can improve availability. You can create replicas of the primary server within the same region or across different global Azure regions where Azure Database for PostgreSQL flexible server is available. In region replicas can provide replication options over default HA solutions. In region Read Replica can reduce read latency. Cross-region read replicas protect databases from region-level failures, using PostgreSQL's physical replication technology. They are available in general purpose and memory-optimized compute tiers and are updated asynchronously, which may result in some lag behind the primary server. 

![screenshot](readreplica.png)

# Azure database for PostgreSQL Resiliency features:  
**Zonal Outage Protection**  \
Azure Database for PostgreSQL - Flexible Server supports both zone-redundant and zonal models for high availability configurations. Both high availability configurations enable automatic failover capability with zero data loss during both planned and unplanned events. 

- **Zone-redundant** \
 Zone redundant high availability deploys a standby replica in a different zone with automatic failover capability. Zone redundancy provides the highest level of availability but requires you to configure application redundancy across zones. For that reason, choose zone redundancy when you want protection from availability zone level failures and when latency across the availability zones is acceptable. Zone-redundancy model offers uptime SLA of 99.99% . In zone-redundant and zonal models, automatic backups are performed periodically from the primary database server. At the same time, the transaction logs are continuously archived in the backup storage from the standby replica. If the region supports availability zones, backup data is stored on zone-redundant storage (ZRS). In regions that don't support availability zones, backup data is stored on local redundant storage (LRS) 
**Regional Outage Protection** \
Azure Database for PostgreSQL safeguard your data against regional outages, ensuring protection during unforeseen events like disasters or other unexpected circumstances.

**Regional Disaster Protection** \
In the event of a region-wide disaster, Azure offers robust protection by leveraging disaster recovery mechanisms across different regions. This approach ensures resilience against regional or large-scale geographic disasters, providing a reliable fallback to another region. For a detailed understanding of Azure's disaster recovery architecture, refer to the Azure to Azure Disaster Recovery Architecture. 


# Reference Architectures

There are 3 variants in the Azure Databases for PostgreSQL Resiliency architecture:

- **Zonal Resilience - without Read Replica**: \
This has one primary instance of Azure PostgreSQL Flexible server instance and is enabled with High Availability. In this configuration when we enable high availability for this instance we can deploy the standby instance with two options by changing the "mode" attribute. There are two values for this attribute:
   
   **1. ZoneRedundant** \- Deploying standby in different zone. [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Fzoneredundanttemplate.json) 
   
    ![screenshot](Azure-PostgreSQL-Reslience-Architecture-v1.1.png)
   
   **2. Same Zone** \- Deploying standby instance in the same zone as that of primary [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Fsamezonetemplate.json)

     ![screenshot](samezone.png)

- **Zonal Resilience - with Read Replica**  [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Freadreplica.json)
   
    This configuration has one instance of Azure PostgreSQL Flexible Server and two read replicas in same region as that of primary instance. In this type we can configure the "zone" attribute which is specifies the value 
    for Availability zone like we have in the portal. We have 3 Availability zones in Azure PostgreSQL Flexible Server. The value added here depends on what is the value added for the Primary instance
   
![screenshot](Flex_ZR-HA_InRegion.png)

- **Regional Resilience** [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Fcrossregionreplica.json)

   Azure PostgreSQL supports deployment of 5 read replicas in any region. In this type of configuration we have 2 read replicas in the same region as that of primary and three read replicas are deployed in a different 
   region to that of the primary server. 

![screenshot](Flex_ZR-HA_CrossRegion.png)

## Terraform script

You can also try deploying this solution accelerator with Terraform script. Follow these steps mentioned below to create the configuration for Resiliency architecture.

## Prerequisites

- Azure account
- Azure CLI installed
- Terraform installed

## Steps to execute the terraform script

1. **Go to Azure portal and launch the CLI**

   Open the Azure portal and launch the Cloud Shell or use your local terminal with Azure CLI installed. On the Azure Cli upload all the terraform files.

2. **Set account subscription**

   Set your Azure subscription using the following command:
   ```sh
   az account set --subscription <subscription-name>
   ```
3.  **Upload all files**

4. **Execute different versions of terraform file**

   a. **Zonal Resilience - without Read Replica**

      This has a script that will just deploy Azure PostgreSQL Flexible server instance with high avaliability enabled attribute. Edit the "variables.tf" file with your subscription-id, desired names, version etc for all the resources.

   b. **Zonal Resilience - with Read Replica**
      
      This script has 2 files: First file is a variables file, please add values to different attributes in this file.  and second file "main.tf" has all the modules and resources that would be deployed with two read replicas in the same region as that of the Primary instance.
   
   c. **Regional Resilience**

      This script has 2 files: First file is a variables file, please add values to different attributes in this file.  and second file "main.tf" has all the modules and resources that would be deployed with two read replicas in the same region as that of the Primary instance and 3 read replicas in a different region as that of Primary instance.

# Steps to run a terraform file:     

1. **Initialize Terraform**

   Initialize your Terraform configuration. This will download the necessary provider plugins:
   ```sh
   terraform init -upgrade
   ```
2. **Create an execution plan**

    Generate and save an execution plan to review the changes Terraform will make:
    ```sh
   terraform plan -out <file-name>
   ```
3. **Apply the plan**
   This command will apply the generated terraform plan:
   ```sh
    terraform apply <file-name>.tfplan
