param virtualNetworkName string
param subnetName string
param subnetAddressPrefix string
param nsgId string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: virtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: virtualNetworkName
}
