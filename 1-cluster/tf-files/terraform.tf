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
  kubectl = {
    source  = "gavinbunney/kubectl"
    version = "~> 1.14"
  }
}
}
