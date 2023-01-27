provider akp {
  org_name = var.akuity_org_name
}

data "akp_instance" "argocd" {
  name    = "tf-managed-demo"
}

resource "akp_cluster" "cluster" {
  instance_id      = data.akp_instance.argocd.id
  name             = "aws-${var.aws_region}"
  namespace        = "akuity"
  size             = "small"
  labels           = {
    # example = "1-cluster"
    cloud   = "aws"
    dev     = "true"
    stage   = "true"
    prod    = "true"
  }
  kube_config = {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.default.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}
