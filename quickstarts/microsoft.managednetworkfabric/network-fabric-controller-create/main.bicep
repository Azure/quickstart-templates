@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param annotation string = ''

@description('A workload management network is required for all the tenant (workload) traffic. This traffic is only dedicated for Tenant workloads which are required to access internet or any other MSFT/Public endpoints')
@allowed([
  'False'
  'True'
])
param isWorkloadManagementNetworkEnabled string = 'True'

@description('Network Fabric Controller SKU')
@allowed([
  'Basic'
  'HighPerformance'
  'Standard'
])
param nfcSku string = 'Standard'

@description('Express route dedicated for Infrastructure services')
param infrastructureExpressRouteConnections array = []

@description('Express route is dedicated for Workload services')
param workloadExpressRouteConnections array = []

@description('Ipv4 address space used for NFC workload management')
param ipv4AddressSpace string = ''

@description('Ipv6 address space used for NFC workload management')
param ipv6AddressSpace string = ''

@description('Create Network Fabric Controller Resource')
resource networkFabricController 'Microsoft.ManagedNetworkFabric/networkFabricControllers@2023-06-15' = {
  name: networkFabricControllerName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    isWorkloadManagementNetworkEnabled: isWorkloadManagementNetworkEnabled
    nfcSku: nfcSku
    infrastructureExpressRouteConnections: [for i in range(0, length(infrastructureExpressRouteConnections)): {
      expressRouteCircuitId: infrastructureExpressRouteConnections[i].expressRouteCircuitId
      expressRouteAuthorizationKey: infrastructureExpressRouteConnections[i].expressRouteAuthorizationKey
    }]
    workloadExpressRouteConnections: [for i in range(0, length(workloadExpressRouteConnections)): {
      expressRouteCircuitId: workloadExpressRouteConnections[i].expressRouteCircuitId
      expressRouteAuthorizationKey: workloadExpressRouteConnections[i].expressRouteAuthorizationKey
    }]
    ipv4AddressSpace: !empty(ipv4AddressSpace) ? ipv4AddressSpace : null
    ipv6AddressSpace: !empty(ipv6AddressSpace) ? ipv6AddressSpace : null
  }
}

output resourceID string = networkFabricController.id
