---
description: This template creates a new Azure Monitor workbook for cost optimization based on the Well-Architected Framework.
page_type: sample
products:
- azure
- azure-advisor
- azure-app-service
- azure-app-service-web
- azure-application-gateway
- azure-blob-storage
- azure-cost-management
- azure-disk-storage
- azure-kubernetes-service
- azure-load-balancer
- azure-monitor
- azure-resource-manager
- azure-sql-database
- azure-sql-managed-instance
- azure-storage-accounts
- azure-virtual-machines
- azure-web-apps
- sql-server
urlFragment: optimization-workbook
languages:
- bicep
- json
---

# FinOps cost optimization workbook

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/optimization-workbook/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/optimization-workbook/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/optimization-workbook/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/optimization-workbook/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/optimization-workbook/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/optimization-workbook/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/optimization-workbook/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Foptimization-workbook%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Foptimization-workbook%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Foptimization-workbook%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Foptimization-workbook%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Foptimization-workbook%2Fazuredeploy.json)

This template creates a new Azure Monitor workbook for **cost optimization**.

The objective of this workbook is to provide an overview of the cost posture of your Azure environment. The workbook is to be used as guidance only and does not represent a guarantee of any cost reduction.

To learn more about the cost optimization workbook, the roadmap, or how to contribute, see [FinOps toolkit documentation](https://aka.ms/finops/toolkit).

<br>

## 📗 How to use this template

Once your workbook is deployed, you can use it by navigating to one of the following destinations:

1. From Azure Monitor:
   1. Select [**Workbooks**](https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/workbooks) in the menu.
   2. Verify your subscription is selected in the **Subscription** filter.
   3. Select the **Cost optimization** workbook.
2. From the resource group:
   1. Select the workbook resource.
   2. Select **Workbook** in the menu.
3. From [Azure workbooks](https://portal.azure.com/#browse/microsoft.insights%2Fworkbooks):
   1. Select the **Cost optimization** workbook.
   2. Select **Workbook** in the menu.

> ℹ️ _**Pro tip:** If you navigate to the workbook resource (2 or 3 above), consider adding the workbook as a favorite using the star icon to the right of the resource name to make it easier to find in the future. Favorite resources can be opened directly from the Resources > Favorite section of the Azure portal default home page._

<br>

## 🧰 About the FinOps toolkit

The cost optimization workbook is part of the [FinOps toolkit](https://aka.ms/finops/toolkit), an open source collection of FinOps solutions that help you manage and optimize your cost, usage, and carbon.

To contribute to the FinOps toolkit, [join us on GitHub](https://aka.ms/ftk).

<br>

`Tags: finops, cost, optimization, Microsoft.Insights/workbooks`
