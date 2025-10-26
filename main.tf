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

# GitOps
