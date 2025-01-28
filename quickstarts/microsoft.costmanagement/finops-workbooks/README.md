---
description: This template deploys Azure Monitor workbooks from the FinOps toolkit that can help engineers perform key tasks defined by the FinOps Framework.
page_type: sample
products:
  - azure
urlFragment: finops-workbooks
languages:
  - bicep
  - json
---

# FinOps workbooks template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-workbooks/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-workbooks/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-workbooks/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-workbooks/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-workbooks/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-workbooks/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-workbooks/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-workbooks%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-workbooks%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-workbooks%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-workbooks%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.costmanagement%2Ffinops-workbooks%2Fazuredeploy.json)

This template deploys a set of workbooks that help you implement FinOps capabilities. FinOps workbooks are tools designed for engineers with direct access to resources to manage and optimize cloud resources.

FinOps workbooks include:

- **Optimization** - Supports workload and rate optimization, sustainability, and security, and more as defined by the Well Architected Framework.
- **Governance** - Supports policy compliance and cloud governance scenarios as defined by the Well Architected Framework.

To learn more about FinOps workbooks, the roadmap, or how to contribute , see [FinOps workbooks documentation](https://aka.ms/finops/workbooks).

<br>

## 📋 Prerequisites

Azure Monitor workbooks provide direct access to Azure resource details. To deploy workbooks, you must have the **Workbook Contributor** role. To use workbooks, you need read access to the resources being monitored. The exact permissions vary by resource and service.

If you run into any issues, see [Troubleshooting FinOps toolkit solutions](https://aka.ms/ftk/tsg).

<br>

## 📗 How to use this template

Once your workbooks are deployed, you can use them by navigating to one of the following destinations:

1. From Azure Monitor:
   1. Select [**Workbooks**](https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/workbooks) in the menu.
   2. Verify your subscription is selected in the **Subscription** filter.
   3. Select the applicable workbook.
2. From the resource group:
   1. Select the desired workbook resource.
   2. Select **Workbook** in the menu.
3. From [Azure workbooks](https://portal.azure.com/#browse/microsoft.insights%2Fworkbooks):
   1. Select the desired workbook.
   2. Select **Workbook** in the menu.

> ℹ️ _**Pro tip:** If you navigate to the workbook resource (2 or 3 above), consider adding the workbook as a favorite using the star icon to the right of the resource name to make it easier to find in the future. Favorite resources can be opened directly from the Resources > Favorite section of the Azure portal default home page._

<br>

## 🧰 About the FinOps toolkit

FinOps workbooks are part of the [FinOps toolkit](https://aka.ms/finops/toolkit), an open source collection of FinOps solutions that help you manage and optimize your cost, usage, and carbon.

To contribute to the FinOps toolkit, [join us on GitHub](https://aka.ms/ftk).

<br>

`Tags: finops, cost, usage, carbon, optimization, policy, governance, Microsoft.Insights/workbooks`
