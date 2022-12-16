provider "azurerm" {
  features {}
}

locals {
  aks_cluster_name = "aks-example-1"
  aks_subnet_name = "example-subnet"
  aks_dns_prefix = "aks1"
}

