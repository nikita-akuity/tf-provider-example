terraform {
required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 3.0"
  }
  akp = {
    source = "akuity/akp"
    version = "0.1.1"
  }
  kubernetes = {
    source = "hashicorp/kubernetes"
    version = "2.16.1"
  }
}
}
