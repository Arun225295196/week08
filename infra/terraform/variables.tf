variable "location" {
  description = "Azure region where the resources will be created"
  type        = string
  default     = "australiaeast"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group (GitHub variable AKS_RESOURCE_GROUP)"
  type        = string
}

variable "acr_name" {
  description = "Globally unique name of the Azure Container Registry (GitHub variable ACR_NAME)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "The ACR name must be 5-50 alphanumeric characters."
  }
}

variable "storage_account_name" {
  description = "Globally unique name of the Storage Account (GitHub variable STORAGE_ACCOUNT_NAME)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "The storage account name must contain 3-24 lowercase letters and numbers."
  }
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster (GitHub variable AKS_CLUSTER_NAME)"
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool (3 = staging + production + monitoring)"
  type        = number
  default     = 3
}

variable "aks_node_vm_size" {
  description = "VM size used by the AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version (null = current AKS default)"
  type        = string
  default     = null
}

variable "create_acr_role_assignment" {
  description = "Grant the AKS kubelet identity AcrPull on the registry (needs Owner/User Access Administrator)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to Azure resources"
  type        = map(string)
  default = {
    Project   = "KoalaTech Course Platform"
    ManagedBy = "Terraform (GitHub Actions)"
    Practical = "Week10-10.2D"
  }
}
