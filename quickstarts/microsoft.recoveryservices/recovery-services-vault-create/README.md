---
description: This template creates a Recovery Services vault that will be used further for Backup and Site Recovery.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: recovery-services-vault-create
languages:
- bicep
- json
---

# Create a Recovery Services vault with advanced options

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.recoveryservices/recovery-services-vault-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-vault-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-vault-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.recoveryservices%2Frecovery-services-vault-create%2Fazuredeploy.json)

This template creates a Recovery Services Vault which will be used further for Backup and SiteRecovery. To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/site-recovery/quickstart-create-vault-template) article.

A disaster recovery and data protection strategy keeps your business running when unexpected events occur.

The Backup service is Microsoft's born in the cloud backup solution to backup data that's located on-premises and in Azure. It replaces your existing on-premises or offsite backup solution with a reliable, secure and cost competitive cloud backup solution. It also provides the flexibility of protecting your assets running in the cloud. You can backup Windows Servers, Windows Clients, Hyper-V VMs, Microsoft workloads, Azure Virtual Machines (Windows and Linux) with its in-built resilience and high SLAs. [Learn more](http://aka.ms/backup-learn-more/).

The Site Recovery service ensures your servers, virtual machines, and apps are resilient by replicating them so that when disasters and outages occur you can easily fail over to your replicated environment and continue working. When services are resumed you simply failback to your primary location with uninterrupted access. Site Recovery helps protect a wide range of Microsoft and third-party workloads. [Learn more](http://aka.ms/asr-learn-more/).

## Storage Type Selection

A Recovery Services vault can only change storage options before any backups have been configured. Once any backup is configured, the storage type cannot be changed. [Learn more](https://docs.microsoft.com/azure/backup/backup-azure-backup-faq#can-i-change-the-storage-redundancy-setting-after-a-backup).

## Cross Region Restore
A Recovery Services vault can only change cross region restore before any backups have been configured. Once any backup is configured, cross region support setting cannot be changed. [Learn more](https://docs.microsoft.com/azure/backup/backup-create-rs-vault#set-cross-region-restore).

## Delete an Azure Backup Recovery Services vault
In order to delete the recovery services vault, you first need to stop protection to any existing backup items. You may refer [Delete Recovery Services Vault](https://docs.microsoft.com/azure/backup/backup-azure-delete-vault#delete-the-recovery-services-vault-by-force)

`Tags: Microsoft.RecoveryServices/vaults, Microsoft.RecoveryServices/vaults/backupstorageconfig`
