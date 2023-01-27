provider akp {
  org_name = var.akuity_org_name
}

data "akp_instance" "argocd" {
  name    = "tf-managed-demo"
}

resource "akp_cluster" "cluster" {
  instance_id      = data.akp_instance.argocd.id
  name             = "gke-${var.google_region}"
  namespace        = "akuity"
  size             = "small"
  labels           = {
    # example = "1-cluster"
    cloud   = "gcp"
    dev     = "true"
    stage   = "true"
    prod    = "true"
  }
  kube_config = {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}
