---
description: This template will help support the new API versions of Microsoft.Insights/components.  Starting with 2020-02-02-preview WorkspaceID will be required when creating Application Inisghts.This template will deploy the App Service Plan, App Service, Application Insights, Log Analytics Workspace and hook it all together.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: web-app-loganalytics
languages:
- json
- bicep
---
# Web App w/ Application Insights sending to Log Analytics

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-loganalytics/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-loganalytics/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-loganalytics/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-loganalytics/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-loganalytics/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-loganalytics/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/web-app-loganalytics/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-loganalytics%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-loganalytics%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fweb-app-loganalytics%2Fazuredeploy.json)

This template will is to help support the new API versions of microsoft.insights/components.  Starting with 2020-02-02-preview an [Workspace Resource ID](https://docs.microsoft.com/azure/templates/microsoft.insights/2020-02-02-preview/components) will be required.
This template will deploy the App Service Plan, App Service, Application Insights, Log Analytics Workspace and hook it all together.

`Tags: Azure, App Service Plan, App Service, Log Analytics, Application Insights, Microsoft.Web/serverfarms, Microsoft.Web/sites, SystemAssigned, Microsoft.Web/sites/config, Microsoft.Web/sites/siteextensions, Microsoft.Insights/components, Microsoft.OperationalInsights/workspaces`

