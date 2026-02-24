terraform {
  required_version = ">= 1.14"

  # Remote state and lock. Run bootstrap first, then init with:
  #   terraform init -reconfigure -backend-config=backend.hcl
  # backend.hcl must set: bucket, region (region must match where the bucket lives).
  # Terraform 1.14+ uses S3-native locking (use_lockfile); DynamoDB from bootstrap is optional.
  backend "s3" {
    key          = "mlops/terraform.tfstate"
    encrypt      = true
    use_lockfile = true
    # bucket and region set via -backend-config=backend.hcl (region must match bucket region)
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
