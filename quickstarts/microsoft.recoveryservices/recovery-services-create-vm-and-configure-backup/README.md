---
description: This template allows you to deploy a Windows VM and Recovery Services Vault configured with the DefaultPolicy for Protection.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: recovery-services-create-vm-and-configure-backup
languages:
- json
- bicep
---
# Deploy a Windows VM and enable backup using Azure Backup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-vm-and-configure-backup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-vm-and-configure-backup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-vm-and-configure-backup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-vm-and-configure-backup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-vm-and-configure-backup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-vm-and-configure-backup/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-create-vm-and-configure-backup/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-create-vm-and-configure-backup%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-create-vm-and-configure-backup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-create-vm-and-configure-backup%2Fazuredeploy.json)

This template allows you to deploy Windows VM and Recovery Services Vault configured with the `DefaultPolicy` for Protection. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/backup/quick-backup-vm-template) article.

If you're new to Azure Backup service, see:

- [Azure Backup service](https://azure.microsoft.com/services/backup/)
- [Azure Backup documentation](https://docs.microsoft.com/azure/backup/)
- [Azure Backup template reference](https://docs.microsoft.com/azure/templates/microsoft.recoveryservices/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Recoveryservices&pageNumber=1&sort=Popular)
  - [Create Recovery Services Vault](../recovery-services-vault-create)
  - [Create Recovery Services Vault and Weekly Backup Policy](../recovery-services-weekly-backup-policy-create)
  - [Create Recovery Services Vault and Daily Backup Policy](../recovery-services-daily-backup-policy-create)

If you're new to the template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

Tags: Azure Backup, Backup, Resource Manager, Resource Manager templates, ARM templates

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.RecoveryServices/vaults, Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems`
