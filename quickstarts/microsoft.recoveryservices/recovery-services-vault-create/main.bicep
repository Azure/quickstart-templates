@description('Name of the Vault')
param vaultName string

@description('Enable CRR (Works if vault has not registered any backup instance)')
param enableCRR bool = true

@description('Change Vault Storage Type (Works if vault has not registered any backup instance)')
@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param vaultStorageType string = 'GeoRedundant'

@description('Location for all resources.')
param location string = resourceGroup().location

var skuName = 'RS0'
var skuTier = 'Standard'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2024-01-01' = {
  name: vaultName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    publicNetworkAccess: 'Enabled' 
  }
}

resource backupStorageConfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2024-01-01' = {
  parent: recoveryServicesVault
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: vaultStorageType
    crossRegionRestoreFlag: enableCRR
  }
}

output location string = location
output name string = recoveryServicesVault.name
output resourceGroupName string = resourceGroup().name
output resourceId string = recoveryServicesVault.id
output systemAssignedMIPrincipalId string = recoveryServicesVault.identity.principalId
