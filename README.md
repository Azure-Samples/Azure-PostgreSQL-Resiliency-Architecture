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
   
3. **Initialize Terraform**

   Initialize your Terraform configuration. This will download the necessary provider plugins:
   ```sh
   terraform init -upgrade
   ```
4. **Create an execution plan***

    Generate and save an execution plan to review the changes Terraform will make:
    ```sh
   terraform plan -out main.tfplan
   ```
5. **Apply the plan**
   This command will apply the generated terraform plan:
   ```sh
    terraform apply main.tfplan
