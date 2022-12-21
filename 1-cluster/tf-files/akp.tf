provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
  username               = azurerm_kubernetes_cluster.example.kube_config.0.username
  password               = azurerm_kubernetes_cluster.example.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
}

provider akp {
  org_name = var.akuity_org_name
}


locals {
  agent_manifests = [ for manifest in split("---", akp_cluster.cluster.manifests) :  yamldecode(manifest)]
}

data "akp_instance" "argocd" {
  name    = "tf-managed-demo"
}

resource "akp_cluster" "cluster" {
  instance_id      = data.akp_instance.argocd.id
  name             = "one"
  namespace        = "akuity"
  size             = "small"
  labels           = {
    example = "1-cluster"
    cloud   = "azure"
    dev     = "true"
    stage   = "true"
    prod    = "true"
  }
}

resource "kubernetes_manifest" "agent_namespace" {
  manifest = local.agent_manifests[0]
  wait {
    fields = {
      "status.phase" = "Active"
    }
  }
}

resource "kubernetes_manifest" "agent" {
    count    = 30
    manifest = element(local.agent_manifests, count.index + 1)
    depends_on = [
        kubernetes_manifest.agent_namespace
    ]
}
