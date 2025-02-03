// Creates a network security group preconfigured for use with Azure ML
// To learn more, see https://docs.microsoft.com/en-us/azure/machine-learning/how-to-access-azureml-behind-firewall
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Name of the network security group')
param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AzureMachineLearning'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '44224'
          sourceAddressPrefix: 'AzureMachineLearning'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'AzureActiveDirectory'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureMachineLearningOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMachineLearning'
          access: 'Allow'
          priority: 150
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureMachineLearningOutbound2'
        properties: {
          protocol: 'UDP'
          sourcePortRange: '*'
          destinationPortRange: '5831'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMachineLearning'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'BatchNodeManagement'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'BatchNodeManagement.${location}'
          access: 'Allow'
          priority: 170
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureResourceManager'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureResourceManager'
          access: 'Allow'
          priority: 180
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureStorageAccount'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage.${location}'
          access: 'Allow'
          priority: 190
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureFrontDoor'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureFrontDoor.FrontEnd'
          access: 'Allow'
          priority: 200
          direction: 'Outbound'
        }
      }
      {
        name: 'MicrosoftContainerRegistry'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'MicrosoftContainerRegistry'
          access: 'Allow'
          priority: 210
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureFrontDoor1stParty'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureFrontDoor.firstparty'
          access: 'Allow'
          priority: 220
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureMonitor'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 230
          direction: 'Outbound'
        }
      }
    ]
  }
}

output networkSecurityGroup string = nsg.id
