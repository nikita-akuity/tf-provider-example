provider aws {
  region = var.aws_region
}

locals {
  eks_cluster_name = "eks-example-1"
  partition        = data.aws_partition.current.partition
  private_subnets  = [for i in range(length(var.aws_zones)) : cidrsubnet(var.aws_cidr_base, 5, i)]
  public_subnets  = [for i in range(length(var.aws_zones)) : cidrsubnet(var.aws_cidr_base, 5, i+length(var.aws_zones))]
}

data "aws_partition" "current" {}

module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "example-network"
  cidr = var.aws_cidr_base

  azs               = var.aws_zones
  private_subnets   = local.private_subnets
  public_subnets    = local.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "shared"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.eks_cluster_name
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true
  eks_managed_node_groups = {
    spot = {
      instance_types = ["c5.xlarge"]
      instance_market_options = {
        market_type = "spot"
      }
      create_security_group = false
      min_size     = 2
      max_size     = 6
      desired_size = 3
    }
  }
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  vpc_id     = module.aws_vpc.vpc_id
  subnet_ids = module.aws_vpc.private_subnets
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}
