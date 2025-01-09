// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI hub name')
param aiHubName string

@description('AI hub display name')
param aiHubFriendlyName string = aiHubName

@description('AI hub description')
param aiHubDescription string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

@description('Resource ID of the AI Services resource')
param aiServicesId string
@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string
@description('Name AI Services resource')
param aiServicesName string
@description('Resource Group name of the AI Services resource')
param aiServiceAccountResourceGroupName string
@description('Subscription ID of the AI Services resource')
param aiServiceAccountSubscriptionId string

@description('Name AI Search resource')
param aiSearchName string
@description('Resource ID of the AI Search resource')
param aiSearchId string
param aiSearchServiceResourceGroupName string
param aiSearchServiceSubscriptionId string

param bingName string
param bingId string
param bingResourceGroupName string
param bingSubscriptionId string


@description('Name for capabilityHost.')
param capabilityHostName string = 'caphost1'

var acsConnectionName = '${aiHubName}-connection-AISearch'

var bingConnectionName = '${aiHubName}-connection-Bing'

var aoaiConnection  = '${aiHubName}-connection-AIServices_aoai'


resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
  scope: resourceGroup(aiServiceAccountSubscriptionId, aiServiceAccountResourceGroupName)
}

resource searchService 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiSearchName
  scope: resourceGroup(aiSearchServiceSubscriptionId, aiSearchServiceResourceGroupName)
}

#disable-next-line BCP081
resource bingSearch 'Microsoft.Bing/accounts@2020-06-10' existing = {
  name: bingName
  scope: resourceGroup(bingSubscriptionId, bingResourceGroupName)
}

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
  }
  kind: 'hub'

  resource aiServicesConnection 'connections@2024-07-01-preview' = {
    name: '${aiHubName}-connection-AIServices'
    properties: {
      category: 'AIServices'
      target: aiServicesTarget
      authType: 'AAD'
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
        location: aiServices.location
      }
    }
  }
  resource hub_connection_azureai_search 'connections@2024-07-01-preview' = {
    name: acsConnectionName
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${aiSearchName}.search.windows.net'
      authType: 'AAD'
      //useWorkspaceManagedIdentity: false
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiSearchId
        location: searchService.location
      }
    }
  }

  resource hub_connection_bing 'connections@2024-07-01-preview' = {
    name: bingConnectionName
    properties: {
      category: 'ApiKey'
      target: 'https://api.bing.microsoft.com/'
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(bingId, '2020-06-10').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: bingId
        location: bingSearch.location
      }
    }
  }

  // Resource definition for the capability host
  #disable-next-line BCP081
  resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
    name: '${aiHubName}-${capabilityHostName}'
    properties: {
      capabilityHostKind: 'Agents'
    }
  }
  
}

output aiHubID string = aiHub.id
output aoaiConnectionName string = aoaiConnection
output acsConnectionName string = acsConnectionName
