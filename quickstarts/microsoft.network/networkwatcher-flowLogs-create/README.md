---
description: This template create an NSG Flow Logs resource
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: networkwatcher-flowLogs-create
languages:
- bicep
- json
---

# Enable NSG Flow Logs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/networkwatcher-flowLogs-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetworkwatcher-flowLogs-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetworkwatcher-flowLogs-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fnetworkwatcher-flowLogs-create%2Fazuredeploy.json)

This template deploys an **NSG flow logs resource** inside the Network Watcher resource group.

## Overview

This template enables a new NSG flow logs resource type `Microsoft.Network/networkWatchers/flowLogs`. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/network-watcher/quickstart-configure-network-security-group-flow-logs-from-arm-template) article.

The flow logs resource is enabled in the (hidden) NetworkWatcherRG resource group that contains the Network Watcher service and related resources. The logs are written to a storage account which is also deployed by the template.

Useful links:

* [Enable NSG Flow logs through an ARM template](https://docs.microsoft.com/azure/network-watcher/network-watcher-nsg-flow-logging-azure-resource-manager)
* [Network Watcher Deployment model](https://docs.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-the-Network-Watcher-deployment-model)
* [What is the NetworkWatcherRG](https://docs.microsoft.com/azure/network-watcher/frequently-asked-questions#what-is-the-NetworkWatcherRG)
* [Permissions needed to deploy to NetworkWatcherRG](https://docs.microsoft.com/azure/network-watcher/frequently-asked-questions#which-permissions-are-needed-to-use-network-watcher)

## Prerequisites

Network Watcher must be enabled for your subscription. Network Watcher is enabled by default, so unless you have disabled it, this should not be an issue.

`Tags: Network Watcher, NSG flow logs, Microsoft.Storage/storageAccounts, Microsoft.Resources/deployments, Microsoft.Network/networkWatchers/flowLogs, JSON, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks`
