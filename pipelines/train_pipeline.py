"""
Kubeflow Pipelines v2: train → (optional evaluate) → register.

Production pattern: one container component that runs our training image (same as CI).
Compile: python pipelines/train_pipeline.py
Upload/run via KFP UI or CLI: kfp run create --experiment mlops-train --pipeline-file pipeline.yaml

Requires: pip install kfp
"""
from __future__ import annotations

import os
from kfp import dsl
from kfp import compiler

# Default: training image from GHCR (set TRAIN_IMAGE or pass at runtime).
DEFAULT_TRAIN_IMAGE = os.environ.get(
    "TRAIN_IMAGE",
    "ghcr.io/kryspinjajko/mlops:latest",
)


@dsl.container_component
def train(
    epochs: int = 50,
    lr: float = 0.01,
    mlflow_tracking_uri: str = "",
    train_image: str = DEFAULT_TRAIN_IMAGE,
):
    """Runs the training container. Logs to MLflow and registers model 'mlops-predictor'."""
    return dsl.ContainerSpec(
        image=train_image,
        command=["python", "-m", "src.train"],
        args=[
            "--epochs", str(epochs),
            "--lr", str(lr),
        ],
        env=[dsl.EnvVar(name="MLFLOW_TRACKING_URI", value=mlflow_tracking_uri)],
    )


@dsl.pipeline(
    name="mlops-train-pipeline",
    description="Train model, log to MLflow, register mlops-predictor.",
)
def train_pipeline(
    epochs: int = 50,
    lr: float = 0.01,
    mlflow_tracking_uri: str = "",
    train_image: str = DEFAULT_TRAIN_IMAGE,
):
    train(
        epochs=epochs,
        lr=lr,
        mlflow_tracking_uri=mlflow_tracking_uri,
        train_image=train_image,
    )


def main() -> None:
    compiler.Compiler().compile(
        pipeline_func=train_pipeline,
        package_path="pipeline.yaml",
    )
    print("Compiled pipeline to pipeline.yaml")


if __name__ == "__main__":
    main()
