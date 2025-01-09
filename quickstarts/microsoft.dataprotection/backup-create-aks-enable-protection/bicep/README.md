# Deploy Azure Backup for AKS

```bash
az deployment sub create --name azure-backup-for-aks-dev --location eastus --template-file main.bicep  --parameters variables.bicepparam
```

## Backup Extension Configuration

| Configuration                                                | Value                                        | Purpose                                                         |
|--------------------------------------------------------------|----------------------------------------------|-----------------------------------------------------------------|
| configuration.backupStorageLocation.bucket                   | k8sbackup                                    | Name of the blob container where the backups are stored         |
| configuration.backupStorageLocation.config.storageAccount    | aksbackupstor                                | Name of the storage account                                     |
| configuration.backupStorageLocation.config.resourceGroup     | aks-backup-rg                                | Name of the resource group where the storage account is located |
| configuration.backupStorageLocation.config.subscriptionId    | <AZURE_SUBSCRIPTION_ID>                      | Subscription ID                                                 |
| credentials.tenantId                                         | <AZURE_TENANT_ID>                            | Azure Tenant ID                                                 |
