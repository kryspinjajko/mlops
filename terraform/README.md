# Terraform: EKS + S3 + ArgoCD for MLOps

Creates the AWS infra: **EKS** (cheapest viable nodes), **S3** data bucket, and **ArgoCD** installed via Helm. State is stored in **S3** with S3-native locking (bootstrap once first).

## What this creates

| Resource | Purpose |
|----------|---------|
| **Bootstrap (run once)** | S3 bucket for Terraform state (locking via S3 lockfile). |
| **VPC** | Subnets in 2 AZs, NAT gateway. |
| **EKS cluster** | One managed node group: **t3.small**, 1–3 nodes (cheapest viable for EKS). |
| **S3 bucket** | Training data; later we’ll trigger pipeline on new data. |
| **ArgoCD** | Installed on EKS via Helm (GitOps; we’ll deploy Kubeflow from here). |

## 1. Bootstrap (state backend, run once)

Creates the S3 bucket for remote state (S3-native locking).

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Create `terraform/backend.hcl` (do not commit) with:

```hcl
bucket = "<state_bucket from bootstrap output>"
region = "<same region as the bucket, e.g. us-east-1>"
```

Copy from `terraform/backend.hcl.example` and fill in.

## 2. Main Terraform

```bash
cd terraform
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

If Helm/ArgoCD fails on first apply (nodes still starting), run `terraform apply` again.

After apply:

- **kubectl:** `aws eks update-kubeconfig --region <region> --name mlops` (or use `terraform output kubeconfig_command`).
- **ArgoCD UI:** `kubectl port-forward svc/argocd-server -n argocd 8080:443` then https://localhost:8080. Admin password: `terraform output -raw argocd_admin_secret_command` then run that command.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | Region for EKS and S3. |
| `cluster_name` | `mlops` | EKS cluster name. |
| `environment` | `dev` | Tag for resources. |
| `repository_url` | `https://github.com/your-org/mlops` | Git repo URL for Argo CD app-of-apps. **Override with your repo** so Argo CD can sync `deploy/argocd-applications` (KFP, etc.). |

Override via `-var` or a `*.tfvars` file (do not commit secrets).

## Argo CD and GitOps (production pattern)

Argo CD is installed by Terraform via Helm. Terraform also creates a single **app-of-apps** Application that syncs from this repo at `deploy/argocd-applications`. All Kubeflow Pipelines (and any other apps) are defined there as Argo CD Application manifests—no `null_resource` or kubectl in Terraform. See `docs/KUBEFLOW_PIPELINES.md`.

## Next steps

1. Install **Kubeflow** (via ArgoCD or Helm).
2. Define the training pipeline and wire **S3 (or schedule) → trigger → Kubeflow run**.
