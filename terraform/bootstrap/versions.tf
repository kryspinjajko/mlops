terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bootstrap uses local state. After this runs once, main terraform uses the S3 backend.
  backend "local" {
    path = "terraform.tfstate"
  }
}
