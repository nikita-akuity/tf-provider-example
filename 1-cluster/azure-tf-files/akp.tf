provider akp {
  org_name = var.akuity_org_name
}

data "akp_instance" "argocd" {
  name    = "tf-managed-demo"
}

resource "akp_cluster" "cluster" {
  instance_id      = data.akp_instance.argocd.id
  name             = "azure-${var.azure_region}"
  namespace        = "akuity"
  size             = "small"
  labels           = {
    purpose = "guestbook"
    cloud   = "azure"
    dev     = "true"
    stage   = "true"
    prod    = "true"
  }
  kube_config = {
    host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
    username               = azurerm_kubernetes_cluster.example.kube_config.0.username
    password               = azurerm_kubernetes_cluster.example.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  }
}
