---
description: This template allows you to deploy a simple alert that uses an action group to send email notifications for any failed Autoscale records in the Azure Activity Log
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: monitor-autoscale-failed-alert
languages:
- json
---
# Deploy an Autoscale Failed Activity Log Alert

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-autoscale-failed-alert/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-autoscale-failed-alert/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-autoscale-failed-alert/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-autoscale-failed-alert/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-autoscale-failed-alert/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/monitor-autoscale-failed-alert/CredScanResult.svg)

The following template deploys an Activity Log Alert with Action Group integrated.

The template deploys an Activity Log Alert with Action Group configured to send email notifications for any failed Autoscale records in the Azure Activity Log. The alert rule will match any failed record in the Activity Log in the Autoscale category.

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmonitor-autoscale-failed-alert%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmonitor-autoscale-failed-alert%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fmonitor-autoscale-failed-alert%2Fazuredeploy.json)

`Tags: Microsoft.Insights/actionGroups, Microsoft.Insights/activityLogAlerts`
