###### VPC Networking #####
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name = "main"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "staging"
  }
}

####### EKS START ######
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = "eks-dev-poc-cluster"
  cluster_version = "1.23"
#   enable_classiclink = false
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "spot"
      }

      taints = [{
        key    = "market"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "staging"
  }
}


#############################
# EKS Blueprints Addons
#############################
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.1"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  # config_path       = "~/.kube/config"

  eks_addons = {
    aws-ebs-csi-driver = {}
  }

  enable_cert_manager         = false
  enable_aws_privateca_issuer = false
  # aws_privateca_issuer = {
  #   acmca_arn = aws_acmpca_certificate_authority.this.arn
  # }

  # tags = local.tags

}
module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"
  eks_cluster_id     = module.eks.cluster_name
  enable_amazon_eks_aws_ebs_csi_driver = true
  amazon_eks_aws_ebs_csi_driver_config = {
  most_recent        = true
  kubernetes_version = "1.23"
  # resolve_conflicts_on_update  = "OVERWRITE"

  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
  config_path = local.kubeconfig

}

# data "aws_eks_cluster" "this" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "ephemeral" {
#   name = module.eks.cluster_name
# }

# locals {
#   kubeconfig = templatefile("./test.tpl", {
#     kubeconfig_name                   = "main_k"
#     endpoint                          = module.eks.cluster_endpoint
#     cluster_auth_base64               = module.eks.cluster_certificate_authority_data
#     aws_authenticator_command         = "aws-iam-authenticator"
#     aws_authenticator_command_args    = ["token", "-i", module.eks.cluster_name]
#     aws_authenticator_additional_args = []
#     aws_authenticator_env_variables   = {}
#     load_config_file       = false
#   })
# }

# output "kubeconfig" { value = "main_k" }

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "ephemeral" {
  name = module.eks.cluster_name
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = module.eks.cluster_name
      }
    }]
  })
}
output "kubeconfig" {
  value       =  local.kubeconfig
  description = "kubeconfig for the AWS EKS cluster"
}