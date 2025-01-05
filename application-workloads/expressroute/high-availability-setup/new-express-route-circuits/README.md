---
description: A template for deploying 2 Express Route Circuits
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: new-express-route-circuits
languages:
- json
---
# High Resiliency Express Route Circuit Deployment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-express-route-circuits/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-express-route-circuits/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-express-route-circuits/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-express-route-circuits/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-express-route-circuits/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/expressroute/high-availability-setup/new-express-route-circuits/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpressroute%2Fhigh-availability-setup%2Fnew-express-route-circuits%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpressroute%2Fhigh-availability-setup%2Fnew-express-route-circuits%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fexpressroute%2Fhigh-availability-setup%2Fnew-express-route-circuits%2Fazuredeploy.json)

This template deploys 2 Express Route Circuits

For more information about how to design and architect Azure ExpressRoute for resiliency check the [official tutorials](https://learn.microsoft.com/en-us/azure/expressroute/design-architecture-for-resiliency).

`Tags: Microsoft.Networkwork/expressroute, expressroute`

# Example parameters for template
$parameters = @{
    # circuit 1 parameters for circuit using service provider:
    circuit1Location          = "eastus"
    circuit1Name              = "circuit1"
    circuit1SkuTier           = "Standard"
    circuit1SkuFamily         = "MeteredData"
    circuit1BandwidthInMbps   = 1000
    circuit1ProviderName      = "AT&T Netbond"
    circuit1PeeringLocation   = "Amsterdam"
    # circuit 2 parameters for circuit using service provider:
    circuit2Location          = "eastus"
    circuit2Name              = "circuit2"
    circuit2SkuTier           = "Standard"
    circuit2SkuFamily         = "MeteredData"
    circuit2BandwidthInMbps   = 2000
    circuit2ProviderName      = "AT&T Netbond"
    circuit2PeeringLocation   = "Amsterdam"
}

$parameters = @{
    # circuit 1 parameters for circuit using direct port:
    circuit1Location             = "eastus"
    circuit1Name                 = "circuit1"
    circuit1SkuTier              = "Standard"
    circuit1SkuFamily            = "MeteredData"
    circuit1DirectId             = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRoutePorts/<portName>"
    circuit1BandwidthInGbps      = 1
    circuit1DirectEnableRateLimiting = $true
    # circuit 2 parameters for circuit using direct port:
    circuit2Location             = "eastus"
    circuit2Name                 = "circuit2"
    circuit2SkuTier              = "Standard"
    circuit2SkuFamily            = "MeteredData"
    circuit2DirectId             = "/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/expressRoutePorts/<portName2>"
    circuit2BandwidthInGbps      = 1
    circuit2DirectEnableRateLimiting = $true
}