---
description: Deploy SQL Always ON setup with existing SQL Virtual Machines. The virtual machines should already be joined to an existing domain and must be running enterprise version of SQL Server.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sql-vm-ag-setup
languages:
- bicep
- json
---
# Deploy SQL Always ON setup with existing SQL Virtual Machines

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.sqlvirtualmachine/sql-vm-ag-setup/BicepVersion.svg)

Before deploying the template you must have the following

1. **Domain** Domain must exist in which the underlying Windows Server Failover Cluster will be created
2. **VM** Virtual Machines in same location, joined to the existing domain

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-ag-setup%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-ag-setup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.sqlvirtualmachine%2Fsql-vm-ag-setup%2Fazuredeploy.json)

`Tags: Azure, SQL, VirtualMachine, AlwaysON, Cluster, Microsoft.SqlVirtualMachine/SqlVirtualMachines, Microsoft.Storage/storageAccounts, Microsoft.SqlVirtualMachine/SqlVirtualMachineGroups, Microsoft.Resources/deployments`

## Solution overview and deployed resources

This deployment will create a WS failover cluster with cloud witness on the provided VMs (in same region) and enable SQL Always ON them. This will enable creating SQL Availability Groups over the created Always ON setup.
Following resources will be created
 - Storage Account to be used as Cloud Witness for failover cluster
 - Resource of type "SqlVirtualMachine" in Microsoft.SqlVirtualMachine resource provider. This corresponds to the existing VirtualMachine
 - Resource of type "SqlVirtualMachineGroup" in Microsoft.SqlVirtualMachine resource provider. This captures details of WS failover cluster setup

