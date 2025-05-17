# Azure Database for PostgreSQL Resiliency Solution Accelerator

# Introduction
We are excited to launch the solution accelerator for deploying Azure Database for PostgreSQL flexible server's resiliency architecture. The architecture is designed to protect data and minimize downtime for mission-critical databases during both planned and unplanned events. This guide includes Terraform scripts and JSON templates to deploy these architectures quickly and efficiently.

# Table of Content
* [Business Continuity Features](#business-continuity-features)
* [Recommended actions to achieve resiliency](#recommended-actions-to-achieve-resiliency)
* [Reference Architectures](#reference-architectures)
* [Deployment scripts and templates](#deployment-scripts-and-templates)
     1. [Deploy with Terraform](terraform)
     2. [Deploy with JSON Script](deploy-with-json-script)

# Business Continuity Features
Azure Database for PostgreSQL flexible server is built on a resilient Azure infrastructure, incorporating features essential for ensuring high availability and fault tolerance, ensuring your databases remain operational. When architecting applications, it is critical to consider the following objectives:

#### 1. Recovery Time Objective (RTO)
RTO is the maximum acceptable downtime for an application. Different applications have varying tolerance levels—for instance, a business-critical database demands much stricter uptime compared to a test database.

#### 2. Recovery Point Objective (RPO)
RPO refers to the maximum acceptable amount of data loss measured in time. Assessing how much data loss your business can tolerate in the event of a disruption is vital.

### Read Replicas
Read replicas enhance performance and availability by creating copies of the primary server either in the same region or across different Azure regions. In-region replicas can improve read performance, while cross-region replicas protect against regional failures using PostgreSQL's physical replication technology. 

### High-Availability
Azure Database for PostgreSQL flexible Server supports both zone-redundant and zonal models for high-availability configurations, providing automatic failover capabilities without any data loss during planned or unplanned events.

- **Zone-Redundant:** Zone-redundant high availability deploys a standby replica in a different availability zone, enabling automatic failover to maintain service continuity. This configuration delivers the highest level of availability and requires configuring application redundancy across zones. Choose zone redundancy when you require robust protection against availability zone failures and when you can tolerate the associated latency between zones. The zone-redundancy model offers an uptime Service Level Agreement (SLA) of 99.99%.

- **Zonal:** Choose a zonal deployment when you want to achieve the highest level of availability within a single availability zone, but with the lowest network latency. Zonal model offers uptime SLA of 99.95%.

   ![screenshot](Images/samezone.png)
  
In both zone-redundant and zonal models, automatic backups are periodically performed from the primary database server, while transaction logs are continuously archived from the standby replica. If the region supports availability zones, backup data will be stored on zone-redundant storage (ZRS). In regions without availability zone support, backup data is stored on local redundant storage (LRS)

### Backup and restore 
Backups form an essential part of any business continuity strategy. They help protect data from accidental corruption or deletion. Azure Database for PostgreSQL Flexible Server takes snapshot backups of data files and stores them securely in zone-redundant storage or locally redundant storage, depending on the region. The server also backs up transaction logs when the write-ahead log (WAL) file is ready to be archived. You can use these backups to restore a server to any point in time within your configured backup retention period.


For flexible servers configured without high availability, the service provides local redundant storage with three copies of data, zone-redundant backup (in regions where it's supported), and built-in server resiliency to automatically restart a crashed server and relocate the server to another physical node. In case if a zone is down, we can perform Point-in-time restore to create a new server with the recovered backup data. Uptime SLA of 99.9% is offered in this configuration.

![screenshot](Images/withoutHA.png)

Geo-redundant backup storage: You can choose this option at the time of server creation. When the backups are stored in geo-redundant backup storage, in addition to three copies of data stored within the region where your server is hosted, the data is replicated to a geo-paired region. Geo-redundancy is supported for servers hosted in any of the [Azure paired regions](azure/reliability/regions-paired).

# Recommended actions to achieve resiliency

### Regional Outage Protection
Azure protects your data against regional outages, ensuring continuity during unforeseen events like disasters. In case of a widespread event, Azure's robust disaster recovery mechanisms can fallback to an alternate region, ensuring reliability.

![screenshot](Images/readreplica.png)

  **Scenario** \
  In the event of a regional failure, you would need to manually promote a read replica in another region to be the new primary server. This process involves changing the read replica's role, which then takes over handling the write operations as the new primary server.
  
  **Recommended Actions** 
 1.  Deploy instances across multiple Azure regions.
 2.  Set up cross-region replication for disaster recovery.
 3.  Implement geo-redundant configurations.
 4.  Ensure automated backups with configurable retention periods.
 5.  Create Virtual Endpoints. These are read-write and read-only listener endpoints, that remain consistent irrespective of the current role of the Azure Database for PostgreSQL flexible server instance
    a. Using Virtual EndPoint with Read Replica:
        The read-only endpoint will point to the new replica which was the former primary 
    b. Use Virtual EndPoint in Parity with Read Replica to failover and failback between replicas
6.  With geo-redundant backup, you can perform a geo-restore in the paired region during an outage, creating a new server with the last available data. Cross-region read replicas can also be promoted to standalone read-write servers during regional failures, with an RPO of up to 5 minutes.
   
 **Impact** \
  In Azure Database for PostgreSQL flexible server, when you make changes to keys or permissions on the primary server, these changes are typically replicated to any read replicas automatically. This replication includes changes to roles, permissions, and other security settings. Read replicas typically provide near-real-time updates from the primary server, but heavy, persistent write activities can lead to increased replication lag and higher storage usage on the primary due to retained WAL files

### Zonal Protection
Zonal protection: We offer an option to host your standby instance in a different zone than the primary instance. You can select this option from the availability zone section on the portal and choose from zones [1, 2, 3]. This ensures that your instance is protected in case of a complete zonal outage. For example, if you select availability zone 1 for the primary instance, the standby instance can be chosen from either zone 2 or 3. Once you make this selection, the WAL server will be created in a zone that is different from both the primary and standby instances.

  **Scenario:**  
  In case of Zonal outage when its Planned like scale computing and scale storage happen on the standby first and then on the primary server. Currently, the server doesn't failover for these planned operations. In case of unplanned failover the standby becomes the new primary and then it creates a new standby in a different zone.
  
  **Recommended Actions:**  
 1.  Configure HA with Zone redundant option and select the zone for Primary and Standby.
 2.  Flexible server health monitoring periodically checks for both the primary and standby health. If health monitoring detects that a primary server isn't reachable, the service then initiates an automatic failover to the standby server. 
 3.  Point-in-restore is recommended for user errors on the primary server like accidental drop of a table or incorrect data updates, from the backup. A new database server is restored as a single-zone flexible server with a new user-provided server name. Possible use cases could be:
    a. Use restored server for production
    b. Restore an object 
    c. Clone your database server to testing and development 
4. Implement monitoring and alerts to ensure timely detection and response. 
5. Use Private Link for secure and seamless failover.
     
**Impact:**  
  In Azure Database for PostgreSQL flexible server, when you make changes to keys or permissions on the primary server, these changes are typically replicated to any read replicas automatically. This replication includes changes to roles, permissions, and other security settings. Read replicas typically provide near-real-time updates from the primary server, but heavy, persistent write activities can lead to increased replication lag and higher storage usage on the primary due to retained WAL files

> Note: In the event of a zonal outage where an entire zone goes down due to unforeseen circumstances, the standby instance created in a different zone will become the primary instance. However, it is not possible to create a new standby server until the affected zone is restored.

# Reference Architectures
In this architecture we recommend using Private endpoint for the Azure Database for PostgreSQL instance. A private endpoint adds a network interface to a resource, providing it with a private IP address assigned from your virtual network. After it's applied, you can communicate with this resource exclusively via the virtual network. Please read more about benefits of using Private link [here](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking-private-link). 
Three variants exist in the Azure Database for PostgreSQL resiliency architecture:

### 1. Zonal Resilience (Without Read Replica)
This configuration includes one primary instance of the Azure PostgreSQL flexible server with high availability enabled. In this configuration, enabling high availability for the instance allows us to deploy the standby instance using two options by modifying the "mode" attribute. This attribute can have either "ZoneRedundant" or "SameZone" value.
   
**Zone Resilient:** Deploying standby in different zone.

![screenshot](Images/zoneredundant1.png)

 **Zone Resilient with Geo-redundant backups:** Deploying standby in a different zone along with Geo-redundant backup storage. This option can be enabled while creating an instance of flexible server.

 ![screenshot](Images/zoneredundantHA.png)
 
### 2. Zonal Resilience (With Read Replica)
This configuration includes one primary instance and two read replicas within the same region. 
 
This configuration includes a single instance of Azure PostgreSQL flexible server along with two read replicas located in the same region as the primary instance. In this setup, you can configure the "zone" attribute, which specifies the value for the Availability Zone, similar to the options available in the portal. Azure PostgreSQL flexible server offers three Availability Zones. You can select any of 1,2,3 availability zones for your primary instance, a standby instance gets deployed in a different zone than that of primary instance. 

![screenshot](Images/inregionreadreplica.png)

### 3. Regional Resilience
This architecture supports one primary instance with two read replicas in the same region and three additional read replicas in a different region. Azure PostgreSQL supports deployment of 5 read replicas in any region. In this type of configuration we have 2 read replicas in the same region as that of primary and three read replicas are deployed in a different region to that of the primary server. 

![screenshot](Images/crossregionreadreplica.png)

# Deployment scripts and templates:
You can use Terraform scripts or JSON templtes to deploy these architectures. 


## Terraform
To deploy this solution using Terraform, follow these steps:
> Note: If you want to use your existing resource-group, remove the resource group block from the "main.tf" file. We have added this block assuming you dont have a resource group created. In the "variables.tf" file edit all the variable names and save the file. 

### Prerequisites:
- An Azure account
- Azure CLI installed on your local terminal
- Terraform installed

### Deployment Steps:

1. **Open Azure CLI**: For this solution accelerator, we are utilizing Azure Cloud Shell. You can launch the Azure portal and access the Cloud Shell, or alternatively, use a local terminal with Azure CLI installed.

2. **Set Account Subscription**: 

   Set your Azure subscription using the following command:
   ```sh
   az account set --subscription <subscription-name>
   ```
3.  **Upload Terraform Files**: Upload the necessary Terraform files.

### Execute Different Versions of Terraform Files:

   - **Zonal Resilience (Without Read Replica)**:

      This has a script that deploys Azure PostgreSQL flexible server instance with high avaliability enabled. Edit the "variables.tf" file with your subscription-id, desired names, version and etc. for all the resources.

   - **Zonal Resilience (With Read Replica)**:

     Modify the variables in the two provided files: "variables.tf" and "main.tf". On "variables.tf" please add values to different attributes; on the second file "main.tf", find all the modules and resources that are deployed with two read replicas in the same region as that of the primary instance.
   
  - **Regional Resilience**:
   
    Similar to the above, edit the necessary files to reflect your configuration
    On "variables.tf" please add values to different attributes; on the second file "main.tf"find all the modules and resources that are deployed with two read replicas in the same region as that of the primary instance and the 3 read replicas in a different region as that of Primary instance.

### Running the Terraform Script:    

Navigate to the Terraform scripts folder, where you'll find separate folders for each of the three architectures. Enter the appropriate folder and follow the steps outlined below.

1. **Initialize Terraform**: 

   Initialize your Terraform configuration. This will download the necessary provider plugins:
   ```sh
   terraform init -upgrade
   ```
2. **Create an Execution Plan**: 

    Generate and save an execution plan to review the changes Terraform will make:
    ```sh
   terraform plan -out <file-name>
   ```
3. **Apply the Plan**: 
   This command will apply the generated terraform plan:
   ```sh
    terraform apply <file-name>.tfplan

## Deploy with JSON script:

You can click the link for each of the architectures to deploy them.

### 1. Zonal Resilience (without Read Replica):

   - **ZoneRedundant:** Deploying standby in different zone. This architecture ensures high availability by deploying the standby instance in a different zone from the primary instance. This setup helps to protect against zone-level failures and provides resilience.

      [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Fzoneredundanttemplate.json) 
   
         
   - **Same Zone:** Deploying standby instance in the same zone as that of primary. This architecture provides high availability by deploying the standby instance in the same zone as the primary instance. It is suitable for scenarios where zone-level redundancy is not required but high availability within the same zone is needed. 
   [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Fsamezonetemplate.json)


### 2. Zonal Resilience (with Read Replica)
This architecture enhances resilience by deploying read replicas in different zones. Read replicas help to offload read operations from the primary instance, improving performance and availability. This setup is ideal for read-heavy workloads and provides zone-level redundancy.

   [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Freadreplica.json)
   

### 3. Regional Resilience
This architecture provides regional resilience by deploying instances across different regions. It ensures high availability and disaster recovery by replicating data across regions. This setup is suitable for mission-critical applications that require protection against regional failures and ensures business continuity. You need to deploy multiple instances of read replica in different regions as that of Primary.

   [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FAzure-PostgreSQL-Resilience-Architecture%2Frefs%2Fheads%2Fdemotemplate%2Fsetup%2Fpostgresinfra%2Fcrossregionreplica.json)

