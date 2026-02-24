# Kubeflow Pipelines on EKS (production-grade, small scale)

This doc describes how we run our ML pipeline on EKS with Kubeflow Pipelines (KFP) and Argo CD, in line with how large-scale MLOps is done (GitOps, pipeline-as-code, containerized steps).

## What we have

- **EKS + Argo CD** (Terraform): cluster and GitOps in place.
- **Full GitOps for KFP** (no `null_resource` or kubectl in Terraform):
  - Terraform creates a single **app-of-apps** Argo CD Application that syncs from this repo at `deploy/argocd-applications`.
  - That directory contains two Application manifests: **kfp-cluster-scoped** (CRDs, sync wave 0) and **kfp-instance** (API, UI, controllers, sync wave 1), both syncing from upstream [kubeflow/pipelines](https://github.com/kubeflow/pipelines). Platform-agnostic = no GCP; runs on EKS.
- **Pipeline definition** (this repo): `pipelines/train_pipeline.py` — one container step that runs our training image (same as CI), logs to MLflow, registers the model.

Set **repository_url** in Terraform to this repo’s Git URL (e.g. `https://github.com/your-org/mlops`) so the app-of-apps can sync `deploy/argocd-applications`.

## Apply Kubeflow Pipelines

```bash
cd terraform
# Set your repo URL if not using default
# export TF_VAR_repository_url=https://github.com/your-org/mlops
terraform apply
```

Terraform only creates the **mlops-apps** Application. Argo CD then syncs that directory and creates **kfp-cluster-scoped** and **kfp-instance**; those sync from upstream. No `null_resource`, no kubectl.

In Argo CD UI you should see **mlops-apps**, **kfp-cluster-scoped**, and **kfp-instance**. Wait until **kfp-instance** is **Synced** and **Healthy**. If it fails once (CRDs not ready), sync again. First full sync can take several minutes.

## Access KFP UI

```bash
kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80
```

Open **http://localhost:8080**. You can create experiments, upload/run pipelines, and view runs.

## Compile and run our pipeline

### 1. Install KFP SDK

```bash
pip install -r pipelines/requirements.txt
```

### 2. Compile pipeline to YAML

```bash
python pipelines/train_pipeline.py
# Creates pipeline.yaml in the current directory.
```

### 3. Run the pipeline

**Option A – KFP UI**

1. Open KFP UI (port-forward above).
2. Create an experiment (e.g. `mlops-train`).
3. Upload `pipeline.yaml` or create a run from the pipeline and fill parameters: `train_image` (e.g. `ghcr.io/YOUR_ORG/mlops/train:latest`), optional `mlflow_tracking_uri`, `epochs`, `lr`.

**Option B – KFP CLI** (if configured against your cluster)

```bash
kfp run create \
  --experiment mlops-train \
  --pipeline-file pipeline.yaml \
  --param train_image=ghcr.io/YOUR_ORG/mlops/train:latest
```

### 4. MLflow tracking

- If you set **MLFLOW_TRACKING_URI** (e.g. to an in-cluster or external MLflow server), the training container will log and register there.
- If you leave it empty, the container will use the default (e.g. local `./mlruns` inside the pod); for production you’d normally point to a shared tracking server and S3 artifact store.

## Production notes (how this matches “big company” setup)

- **GitOps only:** Terraform does not run kubectl or null_resource. It creates one Argo CD Application (app-of-apps); all KFP definitions live in the repo under `deploy/argocd-applications`. Upgrade KFP by changing `targetRevision` in those YAMLs and pushing.
- **Pipeline as code:** The pipeline lives in `pipelines/train_pipeline.py`; it’s versioned and reviewed like application code.
- **Same image as CI:** The pipeline runs the same training image built by GitHub Actions (GHCR), so dev and pipeline use one artifact.
- **Next steps (not done yet):** S3 trigger (e.g. EventBridge → Lambda or CronJob) to start a run when new data lands; in-cluster or external MLflow with S3 backend; and (optional) a second pipeline step for evaluation before register.

## Troubleshooting

### "Error occurred while trying to proxy: localhost:8080/apis/v2beta1/pipelines..."

The KFP UI proxies API requests to the **ml-pipeline** (API) service. This error usually means the API server pod is not running, so the proxy has no backend.

**Common causes:**

1. **Too many pods on the node** — With a single node (e.g. t3.medium, 17 max pods), the scheduler cannot place all KFP components. The **ml-pipeline** pod stays `Pending` with a message like “Too many pods”. **Fix:** Scale the node group (e.g. `desired_size = 2` in Terraform) so the API and other KFP pods can schedule.
2. **Unbound PVCs** — MySQL and Seaweedfs need persistent volumes. If there is no default StorageClass or no EBS CSI driver, their PVCs stay `Pending` and those pods never start; the API may depend on them or the node stays full. **Fix:** Enable the EBS CSI addon and a default StorageClass (e.g. `gp3` with `ebs.csi.aws.com`) so PVCs can bind.

**Check:**

```bash
kubectl get pods -n kubeflow
kubectl describe pod -n kubeflow ml-pipeline-xxx   # look at Events
kubectl get pvc -n kubeflow
```

After scaling nodes and adding storage, wait for **ml-pipeline** (and optionally MySQL/Seaweedfs) to be Running, then refresh the UI.

## References

- [KFP installation (standalone)](https://www.kubeflow.org/docs/components/pipelines/operator-guides/installation/)
- [KFP v2 container components](https://www.kubeflow.org/docs/components/pipelines/v2/components/container-components/)
- [Made With ML – MLOps course](https://madewithml.com/courses/mlops/) (concepts; we use EKS + KFP instead of Anyscale)
