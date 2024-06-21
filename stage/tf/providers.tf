terraform {
  # backend "s3" {
  #   bucket = "whereismyjetpack-tf-state"
  #   key    = "tf/stage"
  #   region = "us-east-1"
  # }
  required_version = "1.8.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.55"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "stage-a"]
    command     = "aws"
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "stage-a"]
    command     = "aws"
  }
}
