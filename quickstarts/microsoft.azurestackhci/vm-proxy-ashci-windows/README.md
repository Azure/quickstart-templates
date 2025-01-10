---
description: This template creates a Windows VM with a proxy configuration from the referenced Azure Marketplace image on Azure Stack HCI version 23H2+
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-proxy-ashci-windows
languages:
- bicep
- json
---
# Create a VM with proxy from the referenced image on Azure Stack HCI

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/vm-proxy-ashci-windows/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/vm-proxy-ashci-windows/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/vm-proxy-ashci-windows/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/vm-proxy-ashci-windows/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/vm-proxy-ashci-windows/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/vm-proxy-ashci-windows/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.azurestackhci/vm-proxy-ashci-windows/BicepVersion.svg)

This template allows you to deploy a new Windows Virtual Machine on an on-premises Azure Stack HCI cluster running 23H2 or newer using the referenced Azure Marketplace image, configuring HTTP and HTTPS proxy settings. The [article](/azure-stack/hci/manage/manage-virtual-machines-in-azure-portal?tabs=arm) walks you through the process and prerequisites.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fvm-proxy-ashci-windows%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fvm-proxy-ashci-windows%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fvm-proxy-ashci-windows%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, there must be an operational ARC Resource Bridge associated with your Azure Stack HCI cluster. The Azure Stack HCI 23H2 and later deployment process will configure the Resource Bridge for you, but you will need to have manually created the Logical Network and Image.

- Custom Location: This is the custom location resource representing your Azure Stack HCI Cluster in Azure. The following Virtual Network and Image resources must be associated with this custom location.
- Azure Stack HCI Logical Network: This resource is the Azure representation of your Hyper-v virtual switch and related network configuration used for the Network Interface created for the new VM. See [Azure Stack HCI Virtual Networks](/azure-stack/hci/manage/create-logical-networks)
- Azure Stack HCI Image: This is a virtual machine image, created from an Azure marketplace gallery image. See [Azure Stack HCI Images](/azure-stack/hci/manage/virtual-machine-image-azure-marketplace)

> [!NOTE]
> For simplicity, this template assumes the Custom Location, Virtual Network, and Image all reside in the same Resource Group as where the Virtual Machine is being created.

`Tags: Microsoft.AzureStackHCI/virtualmachines, hci`