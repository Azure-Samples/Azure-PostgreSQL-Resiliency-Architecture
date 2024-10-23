# Terraform Azure Setup

This guide provides step-by-step instructions to set up and deploy your infrastructure on Azure using Terraform.

## Prerequisites

- Azure account
- Azure CLI installed
- Terraform installed

## Steps

1. **Go to Azure portal and launch the CLI**

   Open the Azure portal and launch the Cloud Shell or use your local terminal with Azure CLI installed. On the Azure Cli upload all the terraform files.

2. **Set account subscription**

   Set your Azure subscription using the following command:
   ```sh
   az account set --subscription "Name"
   ```
3.  **Upload all files**

4. **Execute different versions of terraform file**

   a. **Zonal Resilience - without Read Replica**

      This has a script that will just deploy Azure PostgreSQL Flexible server instance with high avaliability enabled attribute.

   b. **Zonal Resilience - with Read Replica**
      
      This script has 2 files: First file would deploy  Azure PostgreSQL Flexible server instance, and second file "replicas.tf" has two read replicas which would be deployed in the same region as the Flexible server instance

   c. **Regional Resilience**

      This script has 2 files: you can either continue with same configuration created in b option or if not created then execute b option and then just run the 'crossregionreplica.tf' file to deploy 3 read replicas in a different region from Azure PostgreSQL Flexible server instance.

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
