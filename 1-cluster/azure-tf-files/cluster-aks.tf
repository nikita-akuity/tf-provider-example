provider "azurerm" {
  features {}
}

locals {
  aks_cluster_name = "${var.prefix}-tf-example"
  aks_network_name = "${var.prefix}-vpc"
  aks_subnet_name  = "${var.prefix}-subnet"
  aks_dns_prefix   = "${var.prefix}-aks"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-tf-example"
  location = var.azure_region
}

resource "azurerm_virtual_network" "example" {
  name                = local.aks_network_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = [var.azure_cidr_base]
}

resource "azurerm_subnet" "internal" {
  name                 = local.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = [cidrsubnet(var.azure_cidr_base, 4, 1)]
}

resource "azurerm_kubernetes_cluster" "example" {
  name                      = local.aks_cluster_name
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name
  dns_prefix                = local.aks_dns_prefix
  automatic_channel_upgrade = "stable"
  auto_scaler_profile {
    scale_down_unneeded = "4m"
  }

  default_node_pool {
    name                 = "system"
    node_count           = 1
    vm_size              = "standard_ds2_v2"
    vnet_subnet_id       = azurerm_subnet.internal.id
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
  vm_size               = "standard_ds2_v2"
  enable_auto_scaling   = true
  min_count             = 0
  max_count             = 4
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.internal.id
  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}
