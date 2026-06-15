# Week 4 Assignment – Azure Storage and Data Pipeline Development Using Azure Data Factory

## Objective

The objective of this assignment is to understand the fundamentals of Microsoft Azure and implement a complete data movement pipeline using Azure Blob Storage and Azure Data Factory (ADF).

## Technologies and Services Used

* Microsoft Azure
* Azure Blob Storage
* Azure Data Factory (ADF)
* CSV File
* Azure IAM (Identity and Access Management)

## Tasks Performed

### ✅ Step 1 – Setting Up the Resource Group

* Created a Resource Group named **rg-rishika** in the Azure Portal.
* Selected **South India** as the deployment region.

### ✅ Step 2 – Configuring the Storage Account

* Created an Azure Storage Account named **srishikastorage12345**.
* Configured the account with **Standard Performance** and **Locally Redundant Storage (LRS)**.
* Created Blob Storage containers named **input** and **output**.
* Uploaded the **Sample-Superstore.csv** file to the input container.

### ✅ Step 3 – Configuring Azure Data Factory

* Created an Azure Data Factory instance.
* Explored the **Author**, **Monitor**, and **Manage** sections of Azure Data Factory.
* Created a Linked Service named **rishikastorage01** to establish connectivity with Azure Blob Storage.
* Created **SourceDataset** and **DestinationDataset**.
* Configured the **Get Metadata** activity and selected the **Exists** property to verify the availability of the source file.

### ✅ Step 4 – Building the Data Pipeline

* Created a pipeline named **CopyPipeline**.
* Added the **Copy Data** activity to transfer data from the source dataset to the destination dataset.
* Configured and connected the source and destination datasets for data movement.

### ✅ Step 5 – Executing the Pipeline

* Executed the pipeline using the **Debug** option in Azure Data Factory.
* Successfully copied data from the **input** container to the **output** container.

### ✅ Step 6 – Managing IAM Permissions

* Assigned the **Reader** role to provide read-only access to storage resources.
* Granted the **Storage Blob Data Contributor** role to Azure Data Factory, enabling it to read and write data in Azure Blob Storage.

## Pipeline Workflow

```text
Source CSV File
       │
       ▼
Get Metadata Activity
       │
       ▼
Copy Data Activity
       │
       ▼
Destination File (output.csv)
```

## Final Outcome

* Successfully created and configured all required Azure resources.
* Configured Azure Blob Storage and uploaded the source data file.
* Established a secure connection between Azure Data Factory and Azure Blob Storage.
* Created and configured datasets and pipeline activities.
* Validated file availability using the Get Metadata activity.
* Executed the pipeline successfully and generated **output.csv** in the destination container.
