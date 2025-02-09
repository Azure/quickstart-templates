@description('Specify the Windows Failover Cluster Name')
@maxLength(15)
param failoverClusterName string

@description('Specify comma separated list of names of SQL Server VM\'s to participate in the Availability Group (e.g. SQLVM1, SQLVM2). OS underneath should be at least WS 2016.')
param existingVmList string

@description('Specify the SQL Server License type for all VM\'s.')
@allowed([
  'PAYG'
  'AHUB'
])
param sqlServerLicenseType string

@description('Specify resourcegroup name for existing Vms.')
param existingVmResourceGroup string = resourceGroup().name

@description('Select the version of SQL Server Image type')
@allowed([
  'sql2017-ws2019'
  'sql2019-WS2019'
  'sql2019-ws2022'
])
param sqlServerImageType string = 'sql2019-ws2022'

@description('Specify the Fully Qualified Domain Name under which the Failover Cluster will be created. The VM\'s should already be joined to it. (e.g. contoso.com)')
param existingFullyQualifiedDomainName string

@description('Specify an optional Organizational Unit (OU) on AD Domain where the CNO (Computer Object for Cluster Name) will be created (e.g. OU=testou,OU=testou2,DC=contoso,DC=com). Default is empty.')
param existingOuPath string = ''

@description('Specify the account for WS failover cluster creation in UPN format (e.g. example@contoso.com). This account can either be a Domain Admin or at least have permissions to create Computer Objects in default or specified OU.')
param existingDomainAccount string

@description('Specify the password for the domain account')
@secure()
param domainAccountPassword string

@description('Specify the domain account under which SQL Server service will run for AG setup in UPN format (e.g. sqlservice@contoso.com)')
param existingSqlServiceAccount string

@description('Specify the password for Sql Server service account')
@secure()
param sqlServicePassword string

@description('Specify the name of the storage account to be used for creating Cloud Witness for Windows server failover cluster')
param cloudWitnessName string = 'clwitness${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param location string = resourceGroup().location

var existingVMList = split(existingVmList, ',')
var GroupResourceId = failoverCluster.id

resource sqlVM 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2022-08-01-preview' = [for item in existingVMList: {
  name: trim(item)
  location: location
  properties: {
    virtualMachineResourceId: resourceId(existingVmResourceGroup, 'Microsoft.Compute/virtualMachines', trim(item))
    sqlServerLicenseType: sqlServerLicenseType
  }
}]

resource cloudWitness 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: cloudWitnessName
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  location: location
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

resource failoverCluster 'Microsoft.SqlVirtualMachine/SqlVirtualMachineGroups@2022-08-01-preview' = {
  name: failoverClusterName
  location: location
  properties: {
    sqlImageOffer: sqlServerImageType
    sqlImageSku: 'Enterprise'
    wsfcDomainProfile: {
      domainFqdn: existingFullyQualifiedDomainName
      ouPath: existingOuPath
      clusterBootstrapAccount: existingDomainAccount
      clusterOperatorAccount: existingDomainAccount
      sqlServiceAccount: existingSqlServiceAccount
      storageAccountUrl: cloudWitness.properties.primaryEndpoints.blob
      storageAccountPrimaryKey: cloudWitness.listKeys().keys[0].value
    }
  }
}

module joincluster 'modules/join-cluster.bicep' = {
  name: 'joincluster'
  params: {
    existingVirtualMachineNames: existingVMList
    location: location
    sqlServerLicenseType: sqlServerLicenseType
    existingVmResourceGroup: existingVmResourceGroup
    groupResourceId: GroupResourceId
    domainAccountPassword: domainAccountPassword
    sqlServicePassword: sqlServicePassword
  }
  dependsOn: [
    cloudWitness
    sqlVM
  ]
}
