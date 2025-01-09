// Execute this main file to depoy Azure AI studio resources in the basic agent configuraiton wit Managed Identity

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param aiHubName string = 'basic-hub'

@description('Friendly name for your Azure AI resource')
param aiHubFriendlyName string = 'Agents basic hub resource'

@description('Description of your Azure AI resource dispayed in AI studio')
param aiHubDescription string = 'A basic hub resource required for the agent setup.'

@description('Name for the project')
param aiProjectName string = 'basic-project'

@description('Friendly name for your Azure AI project resource')
param aiProjectFriendlyName string = 'Agents basic project resource'

@description('Description of your Azure AI project resource dispayed in AI studio')
param aiProjectDescription string = 'A basic project resource required for the agent setup.'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Model name for deployment')
param modelName string = 'gpt-4o-mini'

@description('Model format for deployment')
param modelFormat string = 'OpenAI'

@description('Model version for deployment')
param modelVersion string = '2024-07-18'

@description('Model deployment SKU name')
param modelSkuName string = 'GlobalStandard'

@description('Model deployment capacity')
param modelCapacity int = 50

@description('Model deployment location. If you want to deploy an Azure AI resource/model in different location than the rest of the resources created.')
param modelLocation string = ''

@description('The AI Service Account full ARM Resource ID. This is an optional field, and if not provided, the resource will be created.')
param aiServiceAccountResourceId string = ''

@description('AI Service Account kind: either OpenAI or AIServices')
param aiServiceKind string = 'AIServices'

// Variables
var name = toLower('${aiHubName}')
var projectName = toLower('${aiProjectName}')

@description('Name of the storage account')
param storageName string = 'agent-storage'

@description('Name of the Azure AI Services account')
param aiServicesName string = 'agent-ai-services'

// Create a short, unique suffix, that will be unique to each resource group
// var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)
param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')
var uniqueSuffix = substring(uniqueString('${resourceGroup().id}-${deploymentTimestamp}'), 0, 4)

var aiServiceExists = aiServiceAccountResourceId != ''

var aiServiceParts = split(aiServiceAccountResourceId, '/')
var aiServiceAccountSubscriptionId = aiServiceExists ? aiServiceParts[2] : subscription().subscriptionId 
var aiServiceAccountResourceGroupName = aiServiceExists ? aiServiceParts[4] : resourceGroup().name

var differentModelLocation = modelLocation != '' ? modelLocation : location

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules-basic/basic-dependent-resources.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    aiServicesName: '${aiServicesName}${uniqueSuffix}'
    aiServiceAccountResourceId: aiServiceAccountResourceId
    storageName: '${storageName}${uniqueSuffix}'
    location: location

     // Model deployment parameters
     modelName: modelName
     modelFormat: modelFormat
     modelVersion: modelVersion
     modelSkuName: modelSkuName
     modelCapacity: modelCapacity
     modelLocation: differentModelLocation
  }
}

module aiHub 'modules-basic/basic-ai-hub-identity.bicep' = {
  name: 'ai-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiHubName: 'ai-${name}-${uniqueSuffix}'
    aiHubFriendlyName: aiHubFriendlyName
    aiHubDescription: aiHubDescription
    location: location
    tags: tags

    // dependent resources
    aiServicesName: aiDependencies.outputs.aiServicesName
    aiServiceKind: aiServiceKind
    aiServiceAccountResourceGroupName: aiDependencies.outputs.aiServiceAccountResourceGroupName
    aiServiceAccountSubscriptionId: aiDependencies.outputs.aiServiceAccountSubscriptionId
    storageAccountId: aiDependencies.outputs.storageId
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
  }
}

module aiProject 'modules-basic/basic-ai-project-identity.bicep' = {
  name: 'ai-${projectName}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiProjectName: 'ai-${projectName}-${uniqueSuffix}'
    aiProjectFriendlyName: aiProjectFriendlyName
    aiProjectDescription: aiProjectDescription
    location: location
    tags: tags

    // dependent resources
    aiHubId: aiHub.outputs.aiHubID
  }
}

module aiServiceRoleAssignments 'modules-basic/ai-service-role-assignments.bicep' = {
  name: 'ai-service-role-assignments-${projectName}-${uniqueSuffix}-deployment'
  scope: resourceGroup(aiServiceAccountSubscriptionId, aiServiceAccountResourceGroupName)
  params: {
    aiServicesName: aiDependencies.outputs.aiServicesName
    aiProjectPrincipalId: aiProject.outputs.aiProjectPrincipalId
    aiProjectId: aiProject.outputs.aiProjectResourceId
  }
}

output PROJECT_CONNECTION_STRING string = aiProject.outputs.projectConnectionString
