// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI Project name')
param aiProjectName string

@description('AI Project display name')
param aiProjectFriendlyName string = aiProjectName

@description('AI Project description')
param aiProjectDescription string

@description('Resource ID of the AI Hub resource')
param aiHubId string

//for constructing project connection string
var subscriptionId = subscription().subscriptionId
var resourceGroupName = resourceGroup().name

var projectConnectionString = '${location}.api.azureml.ms;${subscriptionId};${resourceGroupName};${aiProjectName}'

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiProjectName
  location: location
  tags: union(tags, {
    ProjectConnectionString: projectConnectionString
  })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiProjectFriendlyName
    description: aiProjectDescription

    systemDatastoresAuthMode: 'identity'

    // dependent resources
    hubResourceId: aiHubId
  
  }
  kind: 'project'
}

output aiProjectName string = aiProject.name
output aiProjectResourceId string = aiProject.id
output aiProjectPrincipalId string = aiProject.identity.principalId
output aiProjectWorkspaceId string = aiProject.properties.workspaceId
output projectConnectionString string = aiProject.tags.ProjectConnectionString
