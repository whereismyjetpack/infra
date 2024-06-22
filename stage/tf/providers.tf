terraform {
  # backend "s3" {
  #   bucket = "whereismyjetpack-tf-state"
  #   key    = "tf/stage"
  #   region = "us-east-1"
  # }
  required_version = "1.8.5"
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.55"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}