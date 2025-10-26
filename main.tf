terraform {
  backend "s3" {
    bucket = "jaconsta-msur"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}

locals {
  env_name         = "sandbox"
  aws_region       = "us-east-1"
  k8s_cluster_name = "ms-cluster"
}

# Network
module "aws-network" {
  source                = "github.com/jaconsta/msur-module-aws-network"
  env_name              = local.env_name
  vpc_name              = "ja_msur-VPC"
  cluster_name          = local.k8s_cluster_name
  aws_region            = local.aws_region
  main_vpc_cidr         = "10.0.0.0/16"
  public_subnet_a_cidr  = "10.0.0.0/16"
  public_subnet_b_cidr  = "10.0.64.0/18"
  private_subnet_a_cidr = "10.0.128.0/18"
  private_subnet_b_cidr = "10.0.192.0/18"
}
# EKS
module "aws-eks" {
  source = "github.com/jaconsta/msur-module-aws-kubernetes"

  ms_namespace        = "microservices"
  env_name            = local.env_name
  aws_region          = local.aws_region
  cluster_name        = local.k8s_cluster_name
  vpc_id              = module.aws-network.vpc_id
  cluster_subnets_ids = module.aws-network.subnets_ids

  nodegroup_subnets_ids    = module.aws-network.private-subnets_ids
  nodegroup_disk_size      = "20"
  nodegroup_instance_types = ["t3.medium"]
  nodegroup_desired_size   = 1
  nodegroup_max_size       = 3
  nodegroup_min_size       = 1
}

# GitOps
module "argo-cd-server" {
  source = "github.com/jaconsta/msur-module-argo-cd"

  kubernetes_cluster_id = module.aws-eks.eks_cluster_id
  kubernetes_cluster_name = module.aws-eks.eks_cluster_name
  kubernetes_cluster_cert_data = module.aws-eks.eks_cluster_certificate_data
  kubernetes_cluster_endpoint = module.aws-eks.eks_cluster_endpoint
  eks_nodegroup_id = module.aws-eks.eks_cluster_nodegroup_id
}
