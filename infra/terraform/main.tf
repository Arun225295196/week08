resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------
# Azure Container Registry
# admin_enabled = false: images are pulled with the AKS managed
# identity (AcrPull) instead of a shared admin password.
# ---------------------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

# ---------------------------------------------------------------
# AKS cluster (hosts staging, production and monitoring namespaces)
# ---------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks_cluster_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  count = var.create_acr_role_assignment ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# ---------------------------------------------------------------
# Blob storage for student / lecturer profile photos
# ---------------------------------------------------------------
resource "azurerm_storage_account" "storage" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "student_profile_photo" {
  name                  = "student-profile-photo"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "lecturer_profile_photo" {
  name                  = "lecturer-profile-photo"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}
