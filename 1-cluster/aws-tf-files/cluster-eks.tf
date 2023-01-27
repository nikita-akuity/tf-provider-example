provider aws {
  region = var.aws_region
}

locals {
  eks_cluster_name = "${var.prefix}-tf-example"
  aws_network_name = "${var.prefix}-tf-vpc"
  aws_zones        = data.aws_availability_zones.available.names
  aws_private_subnets  = [for i in range(length(local.aws_zones)) : cidrsubnet(var.aws_cidr_base, 5, i)]
  aws_public_subnets   = [for i in range(length(local.aws_zones)) : cidrsubnet(var.aws_cidr_base, 5, i+length(local.aws_zones))]
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "default" {
  name = local.eks_cluster_name
}

module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.aws_network_name
  cidr = var.aws_cidr_base

  azs               = local.aws_zones
  private_subnets   = local.aws_private_subnets
  public_subnets    = local.aws_public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
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
  cluster_version = "1.24"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  eks_managed_node_groups = {
    initial = {
      instance_types        = ["t3.medium"]
      create_security_group = false
      min_size              = 2
      max_size              = 3
      desired_size          = 2
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
