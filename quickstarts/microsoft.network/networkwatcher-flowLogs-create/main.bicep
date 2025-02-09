@description('Name of the Network Watcher attached to your subscription. Format: NetworkWatcher_<region_name>')
param networkWatcherName string = 'NetworkWatcher_${location}'

@description('Name of your Flow log resource')
param flowLogName string = 'FlowLog1'

@description('Region where you resources are located')
param location string = resourceGroup().location

@description('Resource ID of the target NSG')
param existingNSG string

@description('Retention period in days. Default is zero which stands for permanent retention. Can be any Integer from 0 to 365')
@minValue(0)
@maxValue(365)
param retentionDays int = 0

@description('FlowLogs Version. Correct values are 1 or 2 (default)')
@allowed([
  1
  2
])
param flowLogsVersion int = 2

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

var storageAccountName = 'flowlogs${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

resource networkWatcher 'Microsoft.Network/networkWatchers@2023-09-01' = {
  name: networkWatcherName
  location: location
  properties: {}
}

resource flowLog 'Microsoft.Network/networkWatchers/flowLogs@2023-09-01' = {
  parent: networkWatcher
  name: flowLogName
  location: location
  properties: {
    targetResourceId: existingNSG
    storageId: storageAccount.id
    enabled: true
    retentionPolicy: {
      days: retentionDays
      enabled: true
    }
    format: {
      type: 'JSON'
      version: flowLogsVersion
    }
  }
}

output location string = location
output name string = flowLog.name
output resourceGroupName string = resourceGroup().name
output resourceId string = flowLog.id
