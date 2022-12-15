terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    akp = {
      source = "akuity/akp"
      version = "0.1.0"
    }
  }
}
