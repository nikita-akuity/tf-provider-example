locals {
  example_layout = {
    gcp = {
      dev   = 0
      stage = 0
      prod  = 0
    }
    aws = {
      dev   = 0
      stage = 0
      prod  = 0
    }
    azure = {
      dev   = 0
      stage = 0
      prod  = 0
    }
  }
  // generate cluster names like `dev-gcp-01`
  expanded_layout = {
    for cloud, envs in local.example_layout : cloud => {
      for env_name, count in envs : env_name => [
        for i in range(count) : format("%s-%s-%02d", env_name, cloud, i+1)
      ]
    }
  }
  // generate map of lists like {'gcp' => [<clusers>], 'aws' => [<clusers>]...}
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
  // generate list of maps like [{'dev-gcp-01' => { namespace: 'akuity-dev-01', env: 'dev' }}...]
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

provider akp {
  org_name = var.akuity_org_name
}

// Argo CD Instance
resource "akp_instance" "example" {
  name        = "tf-100-clusters-example"
  version     = "v2.5.7"
  description = "An example of terrafrom automation for managing Akuity Platform resources"
  config = {
    web_terminal = {
      enabled = true
    }
    kustomize = {
      enabled = true
      build_options = "--enable-helm"
    }
  }
  spec = {
    declarative_management = true
  }
}

// All Azure clusters
resource "akp_cluster" "azure_clusters" {
  for_each         = local.azure_clusters
  name             = each.key
  namespace        = each.value.namespace
  namespace_scoped = true
  size             = "small"
  instance_id      = akp_instance.example.id
  labels           = {
    env = each.value.env
    cloud = "azure"
  }
  annotations      = {
    managed-namespace = each.value.namespace
  }
  kube_config      = {
    host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
    username               = azurerm_kubernetes_cluster.example.kube_config.0.username
    password               = azurerm_kubernetes_cluster.example.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  }
}

// All AWS clusters
resource "akp_cluster" "aws_clusters" {
  for_each         = local.aws_clusters
  name             = each.key
  namespace        = each.value.namespace
  namespace_scoped = true
  size             = "small"
  instance_id      = akp_instance.example.id
  labels           = {
    env = each.value.env
    cloud = "aws"
  }
  annotations      = {
    managed-namespace = each.value.namespace
  }
  kube_config      = {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.default.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

// All GCP clusters
resource "akp_cluster" "gcp_clusters" {
  for_each         = local.gcp_clusters
  name             = each.key
  namespace        = each.value.namespace
  namespace_scoped = true
  size             = "small"
  instance_id      = akp_instance.example.id
  labels           = {
    env = each.value.env
    cloud = "gcp"
  }
  annotations      = {
    managed-namespace = each.value.namespace
  }
  kube_config      = {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}
