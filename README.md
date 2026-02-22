# MLOps Learning Project

A learning project for MLOps on AWS: Kubeflow, MLflow, TensorFlow, PyTorch, and common MLOps engineer scenarios. Built step by step with production-style practices.

**How we build:** Start with basics, add one thing at a time. Every step is explained and backed by docs.

**Where we're heading:** One real-case, production-style MLOps example (data → train → track → register → containerize → pipeline → serve → monitor). The full vision is in `docs/PROJECT_VISION.md` – for reference; we still build slowly, step by step.

## Getting started

```bash
conda env create -f environment.yml
conda activate mlops
```

After changing `environment.yml` or `requirements.txt`: `conda env update -f environment.yml --prune`

## Run training

From repo root with `mlops` env active:

```bash
python -m src.train
```

Optional: `--epochs 100 --data-path data/raw/sample.csv --model-dir models`. Model is written to `models/model.pt`.

## View experiment runs (MLflow)

Runs are stored locally in `mlruns/` (gitignored). To open the UI:

```bash
mlflow ui
```

Then open http://127.0.0.1:5000. You’ll see experiment `mlops-train`, runs with params (epochs, lr, data_path), metrics (loss per epoch), and the logged model artifact. Each run also registers a new **model version** under **Models → mlops-predictor** (single source of truth for “which model to deploy”).

## Run training in Docker

Same training script and deps, running in a container. Data, MLflow runs, and model output stay on the host via volume mounts.

**Build** (from repo root):

```bash
docker build -t mlops-train .
```

**Run** (mount data, mlruns, models so results appear on the host):

```bash
docker run --rm \
  -v "$(pwd)/data:/app/data" \
  -v "$(pwd)/mlruns:/app/mlruns" \
  -v "$(pwd)/models:/app/models" \
  mlops-train --epochs 30
```

Override any CLI arg by passing it after the image name, e.g. `mlops-train --epochs 50 --lr 0.02`. Then run `mlflow ui` on the host to see the run.

## CI: Build training image (GitHub Actions)

Workflow: [`.github/workflows/docker-build.yml`](.github/workflows/docker-build.yml).

| Trigger | What runs |
|--------|------------|
| **Push to `main`** | Build image, push to [GitHub Container Registry (GHCR)](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) as `ghcr.io/<owner>/<repo>:latest` and `ghcr.io/<owner>/<repo>:<sha>`. |
| **Pull request to `main`** | Build only (no push). Confirms Dockerfile and `requirements.txt` work. |

After the first push to `main`, the image is under **Packages** in the repo. To run it locally: `docker run --rm -v "$(pwd)/data:/app/data" -v "$(pwd)/mlruns:/app/mlruns" -v "$(pwd)/models:/app/models" ghcr.io/<owner>/<repo>:latest --epochs 30` (for a private repo you may need to log in: `docker login ghcr.io` with a PAT).

---

*We add features incrementally. No tooling or sections ahead of what we implement.*
