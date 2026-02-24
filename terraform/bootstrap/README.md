# Bootstrap: state backend (S3)

Creates the S3 bucket used by the **main** Terraform as remote backend. Locking uses S3-native locking (Terraform 1.14+), so no DynamoDB table.

**Run once**, before first `terraform apply` in the parent directory:

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Then create `../backend.hcl` (parent dir, i.e. `terraform/`) with (use the output values):

```hcl
bucket = "<state_bucket from output>"
region = "<same region as the bucket, e.g. us-east-1>"
```

Then in the main terraform:

```bash
cd ..
terraform init -reconfigure -backend-config=backend.hcl
terraform apply
```

Do not commit `backend.hcl` (root `.gitignore` excludes it).
