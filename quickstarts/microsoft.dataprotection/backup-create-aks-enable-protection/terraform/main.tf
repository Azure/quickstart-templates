#Get Subscription and Tenant Id from Config

data "azurerm_client_config" "current" {
}

#Create a Resource Group where Backup Vault and AKS Cluster will be created
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

#Create a Resource Group where Storage Account and Snapshots related to backup will be created
resource "azurerm_resource_group" "backuprg" {
  location = var.backup_resource_group_location
  name = var.backup_resource_group_name
}

#Create an AKS Cluster 
resource "azurerm_kubernetes_cluster" "akscluster" {
  resource_group_name = azurerm_resource_group.rg.name
  name           = var.aks_cluster_name
  location       = azurerm_resource_group.rg.location
  dns_prefix     = var.dns_prefix

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  depends_on = [azurerm_resource_group.rg,azurerm_resource_group.backuprg]
}

#Create a Backup Vault
resource "azurerm_data_protection_backup_vault" "backupvault" {
  name                = var.backupvault_name
  resource_group_name = resource.azurerm_resource_group.rg.name
  location            = resource.azurerm_resource_group.rg.location
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy

  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_kubernetes_cluster.akscluster]
}

#Create a Backup Policy with 4 hourly backups and 7 day retention duration
resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "policy" {
  name                = var.backuppolicy_name
  resource_group_name = var.resource_group_name
  vault_name          = var.backupvault_name

  backup_repeating_time_intervals = ["R/2024-04-14T06:33:16+00:00/PT4H"]
  default_retention_rule {
    life_cycle {
      duration        = "P7D"
      data_store_type = "OperationalStore"
    }
  }
depends_on = [resource.azurerm_data_protection_backup_vault.backupvault]
}

#Create a Trusted Access Role Binding between AKS Cluster and Backup Vault
resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "trustedaccess" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.akscluster.id
  name                  = "backuptrustedaccess"
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.backupvault.id
  depends_on = [resource.azurerm_data_protection_backup_vault.backupvault, azurerm_kubernetes_cluster.akscluster]
}

#Create a Backup Storage Account provided in input for Backup Extension Installation
resource "azurerm_storage_account" "backupsa" {
  name                     = "tfaksbackup1604"
  resource_group_name      = azurerm_resource_group.backuprg.name
  location                 = azurerm_resource_group.backuprg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [azurerm_kubernetes_cluster_trusted_access_role_binding.trustedaccess]
}

#Create a Blob Container where backup items will stored
resource "azurerm_storage_container" "backupcontainer" {
  name                  = "tfbackup"
  storage_account_name  = azurerm_storage_account.backupsa.name
  container_access_type = "private"
  depends_on = [azurerm_storage_account.backupsa]
}

#Create Backup Extension in AKS Cluster
resource "azurerm_kubernetes_cluster_extension" "dataprotection" {
  name = var.backup_extension_name
  cluster_id = azurerm_kubernetes_cluster.akscluster.id
  extension_type = var.backup_extension_type
  configuration_settings = {
    "configuration.backupStorageLocation.bucket" = azurerm_storage_container.backupcontainer.name
     "configuration.backupStorageLocation.config.storageAccount" = azurerm_storage_account.backupsa.name
     "configuration.backupStorageLocation.config.resourceGroup" = azurerm_storage_account.backupsa.resource_group_name
     "configuration.backupStorageLocation.config.subscriptionId" =  data.azurerm_client_config.current.subscription_id
     "credentials.tenantId" = data.azurerm_client_config.current.tenant_id
     "configuration.backupStorageLocation.config.useAAD" = "true"     
     "configuration.backupStorageLocation.config.storageAccountURI" = azurerm_storage_account.backupsa.primary_blob_endpoint
    }
  depends_on = [azurerm_storage_container.backupcontainer]
}

#Assign Role to Extension Identity over Storage Account
resource "azurerm_role_assignment" "extensionrole" {
  scope                = azurerm_storage_account.backupsa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.dataprotection.aks_assigned_identity[0].principal_id
  depends_on = [azurerm_kubernetes_cluster_extension.dataprotection]
}

#Assign Role to Backup Vault over AKS Cluster
resource "azurerm_role_assignment" "vault_msi_read_on_cluster" {
  scope                = azurerm_kubernetes_cluster.akscluster.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backupvault.identity[0].principal_id
  depends_on = [azurerm_kubernetes_cluster.akscluster,resource.azurerm_data_protection_backup_vault.backupvault]
}

#Assign Role to Backup Vault over Snapshot Resource Group
resource "azurerm_role_assignment" "vault_msi_read_on_snap_rg" {
  scope                = azurerm_resource_group.backuprg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backupvault.identity[0].principal_id
  depends_on = [azurerm_kubernetes_cluster.akscluster,resource.azurerm_data_protection_backup_vault.backupvault]
}

#Assign Role to AKS Cluster over Snapshot Resource Group
resource "azurerm_role_assignment" "cluster_msi_contributor_on_snap_rg" {
  scope                = azurerm_resource_group.backuprg.id
  role_definition_name = "Contributor"
  principal_id         = try(azurerm_kubernetes_cluster.akscluster.identity[0].principal_id,null)
  depends_on = [azurerm_kubernetes_cluster.akscluster,resource.azurerm_kubernetes_cluster.akscluster,resource.azurerm_resource_group.backuprg]
}

#Create Backup Instance for AKS Cluster
resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "akstfbi" {
  name                         = "example"
  location                     = azurerm_resource_group.backuprg.location
  vault_id                     = azurerm_data_protection_backup_vault.backupvault.id
  kubernetes_cluster_id        = azurerm_kubernetes_cluster.akscluster.id
  snapshot_resource_group_name = azurerm_resource_group.backuprg.name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.policy.id

  backup_datasource_parameters {
    excluded_namespaces              = []
    excluded_resource_types          = []
    cluster_scoped_resources_enabled = true
    included_namespaces              = []
    included_resource_types          = []
    label_selectors                  = []
    volume_snapshot_enabled          = true
  }

  depends_on = [
    resource.azurerm_data_protection_backup_vault.backupvault,
    azurerm_data_protection_backup_policy_kubernetes_cluster.policy,
    azurerm_role_assignment.extensionrole,
    azurerm_role_assignment.vault_msi_read_on_cluster,
    azurerm_role_assignment.vault_msi_read_on_snap_rg,
    azurerm_role_assignment.cluster_msi_contributor_on_snap_rg
  ]
}