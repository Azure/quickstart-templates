using 'main.bicep'

param resource_prefix = 'aks0324demo'
param resource_location = 'eastus'
param staging_resource_location = 'westus'
param resource_tags = {
  environment: 'customer-demo'
  purpose: 'azure-backup-for-aks'
}
