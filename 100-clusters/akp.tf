locals {
  example_layout = {
    gcp = {
      dev   = 4
      stage = 4
      prod  = 4
    }
    aws = {
      dev   = 4
      stage = 4
      prod  = 4
    }
    azure = {
      dev   = 4
      stage = 4
      prod  = 4
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
  gcp_clusters = {
    for cluster in local.flatten_layout.gcp : cluster.cluster_name => {
      namespace = cluster.namespace
      env = cluster.env_name
    }
  }
  aws_clusters = {
    for cluster in local.flatten_layout.aws : cluster.cluster_name => {
      namespace = cluster.namespace
      env = cluster.env_name
    }
  }
  azure_clusters = {
    for cluster in local.flatten_layout.azure : cluster.cluster_name => {
      namespace = cluster.namespace
      env = cluster.env_name
    }
  }
}

data "google_client_config" "default" {}

provider "kubectl" {
  alias                  = "gke_1"
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  load_config_file       = false
}

data "aws_eks_cluster_auth" "default" {
  name = local.eks_cluster_name
}

provider "kubectl" {
  alias                  = "eks_1"
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.default.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
}

provider "kubectl" {
  alias                  = "aks_1"
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

module "gcp_cluster_agent" {
  for_each    = local.gcp_clusters
  source    = "../modules/cluster-agent"
  providers = {
    kubectl = kubectl.gke_1
  }
  instance_id      = data.akp_instance.argocd.id
  name             = each.key
  namespace        = each.value.namespace
  namespace_scoped = true
  labels = {
    cloud = "gcp"
    # env   = each.value.env
  }
  annotations = {
    managed-namespace = each.value.namespace
  }
}

module "aws_cluster_agent" {
  for_each    = local.aws_clusters
  source    = "../modules/cluster-agent"
  providers = {
    kubectl = kubectl.eks_1
  }
  instance_id      = data.akp_instance.argocd.id
  name             = each.key
  namespace        = each.value.namespace
  namespace_scoped = true
  labels = {
    cloud = "aws"
    # env   = each.value.env
  }
  annotations = {
    managed-namespace = each.value.namespace
  }
}

module "azure_cluster_agent" {
  for_each    = local.azure_clusters
  source    = "../modules/cluster-agent"
  providers = {
    kubectl = kubectl.aks_1
  }
  instance_id      = data.akp_instance.argocd.id
  name             = each.key
  namespace        = each.value.namespace
  namespace_scoped = true
  labels = {
    cloud = "azure"
    # env   = each.value.env
  }
  annotations = {
    managed-namespace = each.value.namespace
  }
}
