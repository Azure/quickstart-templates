---
description: Creates a function app with managed service identity enabled with Application Insights set up for logs and metrics.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: functions-managed-identity
languages:
- bicep
- json
---

# Creates a function app with managed service identity

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/functions-managed-identity/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/functions-managed-identity/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/functions-managed-identity/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/functions-managed-identity/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/functions-managed-identity/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/functions-managed-identity/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/functions-managed-identity/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunctions-managed-identity%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunctions-managed-identity%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunctions-managed-identity%2Fazuredeploy.json)

This template creates a function application on a consumption plan on Windows. It also enables managed identity for the application and returns the principal id as output.

## Managed identities in Azure Functions

You can learn more about [managed identities](https://docs.microsoft.com/azure/app-service/overview-managed-identity) and common scenarios in the [documentation](https://docs.microsoft.com/azure/app-service/overview-managed-identity#obtaining-tokens-for-azure-resources).

Another common scenario is to grant the managed identity access to either resource groups or subscriptions so that the function has permissions to take action on Azure resources. This is useful when using functions to automate Azure operational tasks.

## Grant the managed identity contributor access to the subscription or resource group so it can perform actions

The below command sets the access at the subscription level.

```powershell
$Context = Get-AzContext
New-AzRoleAssignment -ObjectId <principalId> -RoleDefinitionName Contributor -Scope "/subscriptions/$($Context.Subscription)"
```

## Tasks performed by this template

This template performs the following tasks

* Creates a storage account to store the functions code.
* Creates an application insights resource to store logs and metrics for the function.
* Creates a functions application with managed identity enabled, and running on a consumption plan.

For more information about Azure Functions, see the [Azure Functions Overview](https://azure.microsoft.com/documentation/articles/functions-overview/).

`Tags: Microsoft.Web/sites, SystemAssigned, Microsoft.Web/serverfarms, Microsoft.Storage/storageAccounts, Microsoft.Insights/components`
