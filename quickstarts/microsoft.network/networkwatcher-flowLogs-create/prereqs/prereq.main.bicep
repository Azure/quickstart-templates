@description('Address prefix')
param addressPrefix string = '10.0.0.0/16'

@description('Subnet-1 Prefix')
param subnetPrefix string = '10.0.0.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

var virtualNetworkName = 'virtualNetwork1'
var subnetName = 'subnet'
var networkSecurityGroupName = 'networkSecurityGroup1'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'first_rule'
        properties: {
          description: 'This is the first rule'
          protocol: 'Tcp'
          sourcePortRange: '23-45'
          destinationPortRange: '46-56'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 123
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

output existingNSG string = networkSecurityGroup.id
