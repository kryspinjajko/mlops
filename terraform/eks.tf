# EKS cluster and one managed node group. This is the cluster we'll use for
# Kubeflow and ArgoCD later.
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.35"

  # Allow API access from outside VPC (e.g. Terraform/Helm on your machine, kubectl).
  endpoint_public_access  = true
  endpoint_private_access = true

  # Grant the IAM principal running Terraform (and thus Helm/Kubernetes providers) cluster admin via EKS access entry.
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Addons: vpc-cni (and eks-pod-identity-agent) must exist before nodes so they get pod networking.
  addons = {
    vpc-cni = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    coredns  = {}
    kube-proxy = {}
  }

  # t3.medium: 4GB RAM, 17 max pods per node. KFP + Argo CD need more than one node.
  eks_managed_node_groups = {
    default = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Environment = var.environment
  }
}
