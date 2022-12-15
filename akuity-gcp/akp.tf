locals {
  gcp_cluster_num = 1
}

provider akp {
  org_name = var.akuity_org_name
}

resource "akp_instance" "argocd" {
  name    = "tf-managed-example"
  version = "v2.5.3"
}

data "google_client_config" "default" {}

provider "kubectl" {
  alias                  = "gke_1"
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  load_config_file       = false
}

resource "akp_cluster" "gcp_cluster" {
  for_each         = toset([for x in range(local.gcp_cluster_num): tostring(x)])
  name             = "gcp-cluster-${each.value}"
  namespace_scoped = true
  namespace        = "akuity-gcp-${each.value}"
  size             = "small"
  instance_id      = akp_instance.argocd.id
  labels = {
    cloud = "gcp"
  }
  depends_on = [
    module.gke
  ]
}

module "gcp_agent" {
  for_each  = akp_cluster.gcp_cluster
  source    = "../modules/agent"
  providers = {
    kubectl = kubectl.gke_1
  }
  namespace = each.value.namespace
  manifests = each.value.manifests
}
