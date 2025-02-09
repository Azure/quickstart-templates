@description('Security group defined to support PubSub+ message broker system level and default message vpn ports.')
param securityGroupName string = 'solaceSecurity'

@description('Subnet for PubSub+ message brokers.')
param subnetPrefix string = '10.0.0.0/24'

@description('Location for all resources.')
param location string = resourceGroup().location

resource securityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: securityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'outbound'
        properties: {
          priority: 100
          sourceAddressPrefix: subnetPrefix
          protocol: '*'
          destinationPortRange: '*'
          access: 'Allow'
          direction: 'Outbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'ad8741'
        properties: {
          priority: 150
          protocol: 'Tcp'
          sourceAddressPrefix: subnetPrefix
          sourcePortRange: '*'
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '8741'
          destinationAddressPrefix: subnetPrefix
        }
      }
      {
        name: 'ad8300'
        properties: {
          priority: 151
          protocol: '*'
          sourceAddressPrefix: subnetPrefix
          sourcePortRange: '*'
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '8300-8302'
          destinationAddressPrefix: subnetPrefix
        }
      }
      {
        name: 'sshHost'
        properties: {
          priority: 200
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '22'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'ssh'
        properties: {
          priority: 201
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '2222'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'semp'
        properties: {
          priority: 202
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '8080'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'semptls'
        properties: {
          priority: 203
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '1943'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'smf'
        properties: {
          priority: 204
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '55555'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'smfCompressed'
        properties: {
          priority: 205
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '55003'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'smftls'
        properties: {
          priority: 206
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '55443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'webservices'
        properties: {
          priority: 207
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '8008'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'webtls'
        properties: {
          priority: 208
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '1443'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'amqp'
        properties: {
          priority: 209
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '5672'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'mqtt'
        properties: {
          priority: 210
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '1883'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'mqttweb'
        properties: {
          priority: 211
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '8000'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'rest'
        properties: {
          priority: 212
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '9000'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}