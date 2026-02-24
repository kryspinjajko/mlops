# Bootstrap: S3 bucket for Terraform state (locking uses S3-native use_lockfile in Terraform 1.14+).
# Run this once with local state; then use the output to configure the main terraform backend.
# https://www.terraform.io/docs/language/settings/backends/s3.html

resource "aws_s3_bucket" "state" {
  bucket_prefix = "${var.project}-tf-state-"

  tags = {
    Purpose = "terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy    = true
  ignore_public_acls     = true
  restrict_public_buckets = true
}
