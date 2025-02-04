variable "aks_cluster_name" {
  type        = string
  default     = "Contoso_AKS_TF"
  description = "Name of the AKS Cluster."
}

variable "backup_extension_name" {
  type        = string
  default     = "azure-aks-backup"
  description = "Name of the AKS Cluster Extension."
}

variable "backup_extension_type" {
  type        = string
  default     = "microsoft.dataprotection.kubernetes"
  description = "Type of the AKS Cluster Extension."
}

variable "dns_prefix" {
  type        = string
  default     = "contoso-aks-dns-tf"
  description = "DNS Name of AKS Cluster made with Terraform"
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "backup_resource_group_name" {
  type        = string
  default     = "Contoso_TF_Backup_RG"
  description = "Location of the resource group."
}

variable "backup_resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "Contoso_TF_RG"
  description = "Location of the resource group."
}

variable "cluster_id" {
  type        = string
  default     = "/subscriptions/c3d3eb0c-9ba7-4d4c-828e-cb6874714034/resourceGroups/Contoso_TF_RG/providers/Microsoft.ContainerService/managedClusters/Contoso_AKS_TF"
  description = "Location of the resource group."
}

variable "backupvault_name" {
  type        = string
  default     = "BackupVaultTF"
  description = "Name of the Backup Vault"
}

variable "datastore_type" {
  type        = string
  default     = "OperationalStore"
}

variable "redundancy" {
  type        = string
  default     = "LocallyRedundant"
}

variable "backuppolicy_name" {
  type        = string
  default     = "aksbackuppolicytfv1"
}