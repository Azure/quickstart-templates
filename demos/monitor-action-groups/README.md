---
description: This template creates a new Action group on Azure, this action group can be then used for configuring alerts on Azure.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: monitor-action-groups
languages:
- json
- bicep
---
# Create a new action group on Azure.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-action-groups/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-action-groups/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-action-groups/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-action-groups/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-action-groups/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-action-groups/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-action-groups/BicepVersion.svg)

This template deploys an [Action Group](https://docs.microsoft.com/azure/azure-monitor/platform/action-groups) to Azure. An action group is a collection of notification preferences defined by the owner of an Azure subscription. Azure Monitor and Service Health alerts use action groups to notify users that an alert has been triggered.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmonitor-action-groups%2Fazuredeploy.json)  [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmonitor-action-groups%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmonitor-action-groups%2Fazuredeploy.json)

Currently, action groups support the following receivers:
- Email Receivers
- SMS Receivers
- Webhook Receivers
- ITSM Receivers
- Azure App Push Receivers
- Azure Automation RunbookReceivers
- Voice Receivers
- Azure Logic App Receivers
- Azure Function Receivers
- Azure ARM Role Receivers

# Reference

- The latest template for Azure Action Groups can be found [here](https://docs.microsoft.com/azure/templates/microsoft.insights/2019-06-01/actiongroups)
- [Tutorial](https://docs.microsoft.com/azure/azure-monitor/platform/action-groups-create-resource-manager-template) from Azure on how to create action groups via ARM template
- [Introduction Video](https://azure.microsoft.com/resources/videos/azure-friday-azure-monitor-action-groups/)
- [Creating action group via Azure Portal](https://docs.microsoft.com/azure/azure-monitor/platform/action-groups)

## Notes
`Tags: Azure Monitor, Azure Action Groups, microsoft.insights/actionGroups`
