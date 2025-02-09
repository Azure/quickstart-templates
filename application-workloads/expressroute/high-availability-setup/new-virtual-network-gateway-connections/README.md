---
description: A template for deploying 2 Express Route Virtual Network Gateway Connection
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: new-virtual-network-gateway-connections
languages:
- json
---
# High Resiliency Express Route Virtual Network Gateway Connections Deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-virtual-network-gateway-connections/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-virtual-network-gateway-connections/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-virtual-network-gateway-connections/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-virtual-network-gateway-connections/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-virtual-network-gateway-connections/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-virtual-network-gateway-connections/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpressroute%2Fhigh-availability-setup%2Fnew-virtual-network-gateway-connections%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpressroute%2Fhigh-availability-setup%2Fnew-virtual-network-gateway-connections%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpressroute%2Fhigh-availability-setup%2Fnew-virtual-network-gateway-connections%2Fazuredeploy.json)

This template deploys 2 Express Route Virtual Network Gateway Connections

For more information about how to design and architect Azure ExpressRoute for resiliency check the [official tutorials](https://learn.microsoft.com/en-us/azure/expressroute/design-architecture-for-resiliency).

`Tags: Microsoft.Networkwork/expressroute, expressroute`

# Example parameters for template
$parameters = @{
    # Gateway parameters:
    location                        = "francecentral"                             
    virtualNetworkGatewayId1        = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/virtualNetworkGateways/erVng_migrated"  
    # connection 1 parameters:
    connectionName1                = "connection1"                 
    routingWeight1                 = 10                             
    expressRouteGatewayBypass1     = $false                             
    expressRouteId1                = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRouteCircuits/providercircuit1" 
    # connection 2 parameters:
    connectionName2                = "connection2"                     
    routingWeight2                 = 20                                
    expressRouteGatewayBypass2     = $false                            
    expressRouteId2                = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRouteCircuits/providercircuit2"  
}