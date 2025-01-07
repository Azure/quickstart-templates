# palo-alto-ha-hub-spoke
ARM Template to deploy Palo Alto VM-Series in High Availability using Hub and Spoke Topology

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-paloalto-nva-ha/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-paloalto-nva-ha/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-paloalto-nva-ha/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-paloalto-nva-ha/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-paloalto-nva-ha/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-paloalto-nva-ha/CredScanResult.svg)

```
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-paloalto-nva-ha%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-paloalto-nva-ha%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-paloalto-nva-ha%2Fazuredeploy.json)


This template deploys Palo Alto VM-Series Network Virtual Appliances in High Availability, following the Hub-Spoke topology. 

## Deploying Palo Alto VM-Series Network Virtual Appliances in High Availability

This solution deploys a Hub and Spoke Topology with 2 spokes.
In the Hub virtual network 2 VM-Series appliances are deployed within an Availability Set to ensure High Availability. You can customize how many instances you would like to deploy.

The following resources are deployed as part of the solution

### Resource Group

A single resource group that contains the following resources:

- **Virtual Networks**: 3 Virtual Networks, HubVNET, ProdSpokevnet and Devspokevnet
- **Hub Subnets**: Within the HubVNET 3 subnest are created followign the best practices from Aplo Alto (Trust, Untrust and Management Subnet)
- **Availability Set**: One Availability Set where both Network Virtual Appliances are deployed to ensure High Availability
- **Virtual Machines**: 2 Virtual machines that use the latest Palo Alto BYOL image available from the standard Azure gallery
- **Network Interfaces**: 6 Network Interfaces (3 for each Virtual machine (1 Trust, 1 Untrust, 1 Management))
- **Load balancers**: 2 Load Balancers, one to handle all the inbound traffic from the Internet (Untrust subnet), another instance placed to handle all the inbound traffic from the spokes (Trust subnet)

### Diagram

![alt text](images/paloaltodiagram.png "Diagram of the resources created by the template")). 

## Prerequisites

No prerequisites needed for the deployment, if you want an existing Resource Group to host the resources can be used, otherwise a new resource group can be created at the moment of the deployment.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document.

## Notes

It's important to change the password for the local administrator from the parameters.
You will need a valid license to activate your appliance once the deployment concludes.

`Tags: PaloAlto, Vm-Series, HA, ARM template`
