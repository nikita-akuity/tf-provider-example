provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
  username               = azurerm_kubernetes_cluster.example.kube_config.0.username
  password               = azurerm_kubernetes_cluster.example.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}

provider akp {
  org_name = var.akuity_org_name
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
    # example = "1-cluster"
    cloud   = "azure"
    dev     = "true"
    stage   = "true"
    prod    = "true"
  }
}

data "kubectl_file_documents" "agent" {
    content = akp_cluster.cluster.manifests
}

resource "kubectl_manifest" "agent_namespace" {
    yaml_body = element(data.kubectl_file_documents.agent.documents, 0)
    wait      = true
    lifecycle {
      ignore_changes = [
        yaml_body
      ]
    }
}

resource "kubectl_manifest" "agent" {
    count     = 30
    yaml_body = element(data.kubectl_file_documents.agent.documents, count.index + 1)
    # Important!
    wait_for_rollout = false
    depends_on = [
        kubectl_manifest.agent_namespace
    ]
    # Agent manages itself, no need to reapply manifests
    lifecycle {
      ignore_changes = [
        yaml_body
      ]
    }
}
