data "aws_caller_identity" "current" {}
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"


  cluster_name = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol = "-1"
      from_port = 0
      to_port = 0
      type = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  cluster_endpoint_public_access_cidrs = [
    "${chomp(data.http.myip.body)}/32"
  ]

  cluster_addons = {
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
     
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
  }

# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/4ca9187d53bde3cfb1f3672d9a8e23a8032f1145/node_groups.tf
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large"]
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["m6i.large"]
      capacity_type  = "SPOT"
    }
  }

  manage_aws_auth_configmap = false

  aws_auth_users = [ 
    {
    rolearn = data.aws_caller_identity.current.arn
    username = data.aws_caller_identity.current.user_id
    groups = ["system:masters"]
    }
  ]

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}


resource "null_resource" "setup_kubectl" {
  depends_on = [
    module.eks
  ]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name=${var.cluster_name}"
  }
}