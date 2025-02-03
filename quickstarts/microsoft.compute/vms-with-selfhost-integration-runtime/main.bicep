@description('your existing data factory name')
param existingDataFactoryName string

@description('your existing data factory resource group')
param existingDataFactoryResourceGroup string

@description('IR name must be unique in subscription')
param IntegrationRuntimeName string = 'ir-${uniqueString(resourceGroup().id)}'

@description('the node count is between 1 and 4.')
@minValue(1)
@maxValue(4)
param NodeCount int = 1

@description('SKU Size for the VMs')
param vmSize string = 'Standard_D2s_v3'

@description('User name for the virtual machine')
param adminUserName string

@description('Password for the virtual machine')
@secure()
param adminPassword string

@description('your existing vnet name')
param existingVirtualNetworkName string

@description('your virtual machine will be create in the same datacenter with VNET')
param existingVnetLocation string

@description('Name of the existing VNET resource group')
param existingVnetResourceGroupName string

@description('Name of the subnet in the virtual network you want to use')
param existingSubnetInYourVnet string

@description('The base URI where artifacts required by this template are located.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param _artifactsLocationSasToken string = ''

var delimiters = [
  '-'
  '_'
]
var prefix = split(IntegrationRuntimeName, delimiters)[0]
var networkSecurityGroupName = '${IntegrationRuntimeName}nsg'
var subnetId = resourceId(existingVnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', existingVirtualNetworkName, existingSubnetInYourVnet)
var scriptURL = '${_artifactsLocation}/gatewayInstall.ps1${_artifactsLocationSasToken}'

module nestedTemplate 'nested/IRtemplate.bicep' = {
  name: 'nestedTemplate'
  scope: resourceGroup(existingDataFactoryResourceGroup)
  params: {
    existingDataFactoryName: existingDataFactoryName
    IntegrationRuntimeName: IntegrationRuntimeName
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: existingVnetLocation
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp'
        properties: {
          priority: 1000
          sourceAddressPrefix: '*'
          protocol: 'Tcp'
          destinationPortRange: '3389'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

module VMtemplate 'nested/VMtemplate.bicep' = [for i in range(0, NodeCount): {
  name: 'vmCopy-${i}'
  params: {
    virtualMachineName: take('vm${i}-${prefix}', 15)
    vmSize: vmSize
    adminUserName: adminUserName
    adminPassword: adminPassword
    existingVnetLocation: existingVnetLocation
    subnetId: subnetId
    nsgId: networkSecurityGroup.id
  }
  dependsOn: [
    nestedTemplate
  ]
}]

@batchSize(1)
module IRInstalltemplate 'nested/IRInstall.bicep' = [for i in range(0, NodeCount): {
  name: 'irInstallCopy-${i}'
  params: {
    datafactoryId: resourceId(existingDataFactoryResourceGroup, 'Microsoft.DataFactory/factories/integrationruntimes', existingDataFactoryName, IntegrationRuntimeName)
    virtualMachineName: take('vm${i}-${prefix}', 15)
    existingVnetLocation: existingVnetLocation
    scriptUrl: scriptURL
  }
  dependsOn: [
    VMtemplate
    nestedTemplate
  ]
}]
