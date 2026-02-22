# Project vision (reference only)

**Purpose of this file:** This is the north star for the repo – a single, real-case MLOps project we build toward **slowly**. Use it as reference when planning the next step. Do not dump this whole scope on the user at once; we add one piece at a time and explain as we go.

---

## The project: production-grade MLOps in one example

**Scenario:** A small **ML-powered service** that a company could really run – e.g. an internal API that predicts something from input data (e.g. simple demand forecast, or “priority score” for tickets). Data → train → track experiments → register model → package → run in a pipeline → serve → monitor. One end-to-end flow, kept simple so we can focus on MLOps, not ML research.

**Why this scenario:** It’s a real use case, uses standard tools (MLflow, Docker, Kubeflow, AWS), and touches the topics a DevOps engineer needs to become an MLOps engineer: reproducibility, pipelines, containers, model lifecycle, serving, and observability.

---

## Phases we’re heading toward (order may be adjusted)

Each phase is a learning target; we implement only when we get there.

| Phase | What we build (high level) | What we learn (DevOps → MLOps) |
|-------|----------------------------|---------------------------------|
| **1. Repo & env** | Clean repo, dependency management, Python/conda env | Reproducible envs, project layout, version pinning |
| **2. Data & script** | Small dataset, simple training script (e.g. PyTorch or TensorFlow basics) | Data in versioned place, “training” as a runnable script, no magic |
| **3. Experiment tracking** | Log runs and metrics with MLflow (local first) | Why we track experiments, metrics, params, artifacts |
| **4. Model registry** | Register best model in MLflow, version it | Model versions, promotion, single source of truth |
| **5. Containerize** | Docker image for training and/or serving | Reproducible runs, same env in dev and prod |
| **6. Pipeline** | Automate “train → evaluate → register” (e.g. Kubeflow on AWS) | ML pipelines as code, triggers, dependencies |
| **7. Serving** | Serve model via API (containerized), e.g. SageMaker or simple API on EKS | Model serving, latency, versioned endpoints |
| **8. AWS & infra** | Run pipeline and serving on AWS (SageMaker, EKS, or similar) | How ML fits into AWS, IAM, networking, cost |
| **9. Observability** | Logs, metrics, maybe drift/quality checks | Monitoring ML in production, alerts, SLAs |

---

## Out of scope (we don’t need)

- Complex ML research or heavy feature engineering.
- Multiple models or A/B frameworks in this first pass.
- Full platform design (we keep one clear path: one model, one pipeline, one service).

---

## How to use this file

- **For the AI:** When choosing the next step, pick the next logical phase (or a sub-step within it). Don’t implement future phases until we’ve done the groundwork.
- **For the user:** This is just the map. We still build slowly; each session stays focused on one small, explained step.
