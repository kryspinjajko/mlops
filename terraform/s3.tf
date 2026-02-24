# S3 bucket for training data. Pipeline (or you) upload data here; trigger
# will eventually start a Kubeflow run when new objects arrive.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "data" {
  bucket_prefix = "${var.cluster_name}-data-"

  tags = {
    Environment = var.environment
    Purpose     = "mlops-training-data"
  }
}

# Block public access (production default).
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy    = true
  ignore_public_acls     = true
  restrict_public_buckets = true
}

# Optional: versioning so we can trace which data a run used.
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}
