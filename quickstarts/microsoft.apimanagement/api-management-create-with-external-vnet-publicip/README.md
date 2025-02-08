---
description: This template demonstrates how to create an instance of Azure API Management in the Premium tier within your virtual network's subnet in external mode and configure recommended NSG rules on the subnet. The instance is deployed to two availability zones. The template also configures a public IP address from your subscription.
page_type: sample
products:
- azure
- azure-resource-manager
- azure-api-management
urlFragment: api-management-create-with-external-vnet-publicip
languages:
- bicep
- json
---
# Deploy API Management in external VNet with public IP

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-vnet-publicip%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-with-external-vnet-publicip%2Fazuredeploy.json)

This template shows an example of how to deploy an Azure API Management service within your own virtual network's subnet in [external mode](https://docs.microsoft.com/azure/api-management/api-management-using-with-vnet).
In external mode, clients from the internet can connect to the API Management service gateway, while the gateway can access backends available only in the virtual network.

- The template creates a Premium tier API Management instance that is deployed to two availability zones. You may choose to deploy the API Management instance in the Developer tier; however, availability zones are not supported in that tier.
- The template deploys a virtual network and a dedicated subnet that hosts the API Management service.
- The template obtains a Standard SKU public IP address from the customer's subscription.
- The template also deploys a network security group on the API Management subnet, which is based on [recommended configurations](https://aka.ms/apim-vnet-common-issues).
- The template disables all unsecure ciphers and SSL/TLS protocols.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.ApiManagement/service`
