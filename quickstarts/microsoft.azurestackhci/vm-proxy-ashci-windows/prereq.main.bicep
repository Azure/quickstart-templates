@description('The name of an existing Logical Network in your HCI cluster - for example: vnet-compute-vlan240-dhcp')
param logicalNetworkName string
@description('The name of a Hyper-V VM switch in your HCI cluster - usually serving your Compute network. For example: ComputeSwitch(compute)')
param vmSwitchName string
@description('The DNS servers to use for the logical network. Make sure to use local DNS servers for AD-joined systems')
param dnsServers array = [
  '1.1.1.1'
  '8.8.8.8'
]
@description('The VLAN ID for the logical network. If not specified, the default value is 0.')
param vlan int = 0
@description('The address prefix for the logical network - for example: 172.16.0.0/22')
param addressPrefix string
@description('The default gateway for the logical network - for example: 172.16.0.1')
param defaultGateway string
@description('The start IP address for the IP pool - for example: 172.16.1.100')
param startIPAddress string
@description('The start IP address for the IP pool - for example: 172.16.1.200')
param endIPAddress string
param location string = 'eastus'
@description('The name of the custom location to use for the deployment. This name is specified during the deployment of the Azure Stack HCI cluster and can be found on the Azure Stack HCI cluster resource Overview in the Azure portal.')
param customLocationName string

var customLocationId = resourceId('Microsoft.ExtendedLocation/customLocations', customLocationName)

resource marketplaceGalleryImage 'Microsoft.AzureStackHCI/marketplaceGalleryImages@2023-09-01-preview' = {
  name: 'MicrosoftWindowsServer'
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    identifier: {
      publisher: 'microsoftwindowsserver'
      offer: 'windowsserver'
      sku: '2022-datacenter-azure-edition'
    }
    version: {
      name: 'latest'
    }
    osType: 'Windows'
  }
}

resource virtualNetwork 'Microsoft.AzureStackHCI/logicalNetworks@2023-09-01-preview' = {
  name: logicalNetworkName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    subnets: [ {
        name: 'default'
        properties: {
          addressPrefix: addressPrefix
          ipAllocationMethod: 'Dynamic'
          vlan: vlan
          ipPools: [
            {
              start: startIPAddress
              end: endIPAddress
            }
          ]
          routeTable: {
            properties: {
              routes: [
                {
                  name: 'default'
                  properties: {
                    addressPrefix: '0.0.0.0/0'
                    nextHopIpAddress: defaultGateway
                  }
                }
              ]
            }
          }
        }
      } ]
    vmSwitchName: vmSwitchName
    dhcpOptions: {
      dnsServers: dnsServers
    }
  }
}
