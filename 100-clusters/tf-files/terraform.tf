terraform {
required_providers {
  google = {
    source = "hashicorp/google"
    version = "~> 4.46"
  }
  aws = {
    source  = "hashicorp/aws"
    version = "~> 4.0"
  }
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
