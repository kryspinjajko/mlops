output "state_bucket" {
  description = "S3 bucket name for Terraform state. Use in main backend config (backend.hcl)."
  value       = aws_s3_bucket.state.id
}

output "backend_config_instructions" {
  description = "Next step: create backend.hcl in the parent directory with these values."
  value       = <<-EOT
    Create terraform/backend.hcl (do not commit) with:
      bucket = "${aws_s3_bucket.state.id}"
      region = "<same region as this bucket, e.g. us-east-1>"
    Then in terraform/: terraform init -reconfigure -backend-config=backend.hcl
  EOT
}
