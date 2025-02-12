---
description: This template creates an Azure Stack HCI 23H2 cluster in Fairfax using an ARM template.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-cluster-for-fairfax
languages:
- json
---
# creates an Azure Stack HCI 23H2 cluster

This template allows you to create an Azure Stack HCI cluster using version 23H2. First you deploy the template in validate mode which does confirm the parameters at the device. Once passed you re-deploy the template with mode set to deploy.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.azurestackhci%2Fcreate-cluster%2Fazuredeploy.json)

## Prerequisites

In order to deploy this template, you must have Arc enabled the server(s) and installed the mandatory extensions. The following pre-requisites must be completed:
- Register these resource providers
    - Microsoft.HybridCompute
    - Microsoft.GuestConfiguration
    - Microsoft.HybridConnectivity
    - Microsoft.AzureStackHCI
- A Service Principal must be created.
    - Make a note of the SPNs APP ID
    - Make a note of the SPNs Object ID
    - Make a note of the SPNs secret (if not already generated , generate one)
- Make a note of the HCI Resource Provider SPNs Object ID in the tenant.


`Tags: Microsoft.AzureStackHCI/clusters, hci`
