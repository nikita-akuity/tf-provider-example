locals {
  example_layout = {
    gcp = {
      dev = 0
      stage = 0
    }
    aws = {
      dev = 0
      stage = 0
    }
    azure = {
      dev = 0
      stage = 0
    }
  }
  expanded_layout = {
    for cloud, envs in local.example_layout : cloud => {
      for env_name, count in envs : env_name => [
        for i in range(count) : format("%s-%s-%02d", env_name, cloud, i+1)
      ]
    }
  }
  flatten_layout = {
    for cloud, clusters in local.expanded_layout : cloud => flatten([
        for env_name, cluster_names in clusters: [
            for i, cluster_name in cluster_names : {
                env_name = env_name
                cluster_name = cluster_name
                namespace = format("akuity-%s-%02d",env_name, i+1)
            }
        ]
    ])
  }
}

provider akp {
  org_name = var.akuity_org_name
}

data "akp_instance" "argocd" {
  name    = "tf-managed-demo"
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
  for_each         = {for cluster in local.flatten_layout.gcp : cluster.cluster_name => {
    namespace = cluster.namespace
    env = cluster.env_name
  }}
  instance_id      = data.akp_instance.argocd.id
  name             = each.key
  namespace        = each.value.namespace
  namespace_scoped = true
  size             = "small"
  labels = {
    cloud = "gcp"
    env   = each.value.env
  }
  annotations = {
    managed-namespace = each.value.namespace
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
  manifests = each.value.manifests
}
