output "aks_resource_group" {
   value = azurerm_resource_group.rg.name
 }

 output "snapshot_resource_group" {
   value = azurerm_resource_group.backuprg.name
 }

 output "kubernetes_cluster_name" {
   value = azurerm_kubernetes_cluster.akscluster.name
 }

 output "backup_vault_name" {
   value = azurerm_data_protection_backup_vault.backupvault.name
 }

 output "backup_instance_id" {
   value = azurerm_data_protection_backup_instance_kubernetes_cluster.akstfbi.id
 }