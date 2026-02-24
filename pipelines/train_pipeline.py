"""
Kubeflow Pipelines v2: train container component.

Production pattern: one container component that runs our training image (same as CI).
Compile: python pipelines/train_pipeline.py
Upload/run via KFP UI or CLI: kfp run create --experiment mlops-train --pipeline-file pipeline.yaml

Requires: pip install -r pipelines/requirements.txt
"""
from kfp import dsl
from kfp import compiler

TRAIN_IMAGE = "ghcr.io/kryspinjajko/mlops:latest"


@dsl.container_component
def train(
    epochs: int = 50,
    lr: float = 0.01,
):
    """Runs the training container. Image is built and pushed to GHCR by CI."""
    return dsl.ContainerSpec(
        image=TRAIN_IMAGE,
        command=["python", "-m", "src.train"],
        args=["--epochs", str(epochs), "--lr", str(lr)],
    )


@dsl.pipeline(
    name="mlops-train-pipeline",
    description="Train model on EKS via KFP. Logs to MLflow when tracking URI is configured.",
)
def train_pipeline(
    epochs: int = 50,
    lr: float = 0.01,
):
    train(epochs=epochs, lr=lr)


def main() -> None:
    compiler.Compiler().compile(
        pipeline_func=train_pipeline,
        package_path="pipeline.yaml",
    )
    print("Compiled pipeline to pipeline.yaml")


if __name__ == "__main__":
    main()
