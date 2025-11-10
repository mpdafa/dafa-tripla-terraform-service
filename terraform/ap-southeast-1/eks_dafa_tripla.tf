module "eks" {
  source  = "terraform-aws-modules/eks/aws" # https://github.com/terraform-aws-modules/terraform-aws-eks?tab=readme-ov-file#aws-eks-terraform-module
  version = "18.31.2"

  cluster_name    = var.cluster_name
  cluster_version = "1.33"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access          = true
  cluster_endpoint_private_access         = true
  cluster_endpoint_public_access_cidrs    = ["118.99.81.165/32"] # My Home IP

  # Enable logging for observability
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Managed node groups
  eks_managed_node_groups = {
    default = {
      name           = "${var.cluster_name}"
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3

      capacity_type = "ON_DEMAND"

      labels = {
        role = "general"
      }

      tags = {
        Name = "${var.cluster_name}-default"
        Environment = var.environment
      iam_role_use_name_prefix  = false

      }
    }

    #spot = {
    #  name           = "${var.cluster_name}-spot"
    #  instance_types = ["t3.large", "t3a.large"]
    #  capacity_type  = "SPOT"
    #  desired_size   = 1
    #  min_size       = 0
    #  max_size       = 3

    #  labels = {
    #    role = "spot"
    #  }

    #  tags = {
    #    Name = "${var.cluster_name}-spot"
    #    Environment = var.environment
    #  }
    #}
  }

  tags = {
    Environment = var.environment
    Project     = "tripla-eks"
    ManagedBy   = "terraform"
  }
}
