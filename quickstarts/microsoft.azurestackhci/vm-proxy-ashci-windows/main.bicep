@maxLength(15)
param name string
param location string
param vCPUCount int = 2
param memoryMB int = 8192
param adminUsername string
@description('The name of a Marketplace Gallery Image already downloaded to the Azure Stack HCI cluster. For example: winServer2022-01')
param imageName string
@description('The name of an existing Logical Network in your HCI cluster - for example: vnet-compute-vlan240-dhcp')
param hciLogicalNetworkName string
@description('The name of the custom location to use for the deployment. This name is specified during the deployment of the Azure Stack HCI cluster and can be found on the Azure Stack HCI cluster resource Overview in the Azure portal.')
param customLocationName string
@secure()
param adminPassword string
@description('Optional. Proxy server URL for the VM to use for HTTP traffic. Example: http://proxy.contoso.com:8080')
param httpProxy string?
@description('Optional. Proxy server URL for the VM to use for HTTPS traffic. Example: http://proxy.contoso.com:8080')
param httpsProxy string?
@description('Optional. Array of URLs that the VM should not use the proxy server for. Example: ["localhost", "172.16.0.0/12"]')
param noProxy array?
@description('Optional. Trusted CA certificate for the proxy server. Example: "-----BEGIN CERTIFICATE-----\nMIIDdzCCAl..."')
param trustedProxyCA string?

var nicName = 'nic-${name}' // name of the NIC to be created
var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName) // full custom location ID
var marketplaceGalleryImageId = resourceId('microsoft.azurestackhci/marketplaceGalleryImages', imageName) // full marketplace gallery image ID
var logicalNetworkId = resourceId('microsoft.azurestackhci/logicalnetworks', hciLogicalNetworkName) // full logical network ID

// precreate an Arc Connected Machine with an identity--used for zero-touch onboarding of the Arc VM during deployment
resource hybridComputeMachine 'Microsoft.HybridCompute/machines@2023-10-03-preview' = {
  name: name
  location: location
  kind: 'HCI'
  identity: {
    type: 'SystemAssigned'
  }
}

resource nic 'Microsoft.AzureStackHCI/networkInterfaces@2024-01-01' = {
  name: nicName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: logicalNetworkId
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.AzureStackHCI/virtualMachineInstances@2024-01-01' = {
  name: 'default' // value must be 'default' per 2023-09-01-preview
  properties: {
    hardwareProfile: {
      vmSize: 'Custom'
      processors: vCPUCount
      memoryMB: memoryMB
    }
    httpProxyConfig: {
      httpProxy: httpProxy
      httpsProxy: httpsProxy
      noProxy: noProxy
      trustedCa: trustedProxyCA
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: name
      windowsConfiguration: {
        provisionVMAgent: true // mocguestagent
        provisionVMConfigAgent: true // azure arc connected machine agent
      }
    }
    storageProfile: {
      imageReference: {
        id: marketplaceGalleryImageId
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  scope: hybridComputeMachine
}
