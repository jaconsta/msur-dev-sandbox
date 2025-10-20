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

# EKS

# GitOps
