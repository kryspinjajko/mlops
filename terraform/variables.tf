variable "aws_region" {
  description = "AWS region for EKS, S3, and VPC. Must match the region used by the AWS provider (e.g. AWS_DEFAULT_REGION or provider config)."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "mlops"
}

variable "environment" {
  description = "Environment label (e.g. dev, staging)."
  type        = string
  default     = "dev"
}

variable "repository_url" {
  description = "Git repository URL for Argo CD app-of-apps. Must point to this repo so Argo CD can sync deploy/argocd-applications."
  type        = string
  default     = "https://github.com/kryspinjajko/mlops"
}
