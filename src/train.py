"""
Minimal training script: load CSV, train a small PyTorch model, save weights, log to MLflow.

Run from repo root with conda env active:
  python -m src.train
  python -m src.train --epochs 100 --data-path data/raw/sample.csv --model-dir models

Tracking is local by default (./mlruns). View runs: mlflow ui
"""
from __future__ import annotations

import argparse
from pathlib import Path

import mlflow
import mlflow.pytorch
import pandas as pd
import torch
import torch.nn as nn


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Train a small model on data/raw CSV.")
    p.add_argument("--data-path", type=Path, default=Path("data/raw/sample.csv"), help="Path to CSV (feature columns + 'target').")
    p.add_argument("--model-dir", type=Path, default=Path("models"), help="Directory to save model.pt.")
    p.add_argument("--epochs", type=int, default=50, help="Training epochs.")
    p.add_argument("--lr", type=float, default=0.01, help="Learning rate.")
    return p.parse_args()


def main() -> None:
    args = parse_args()
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Load data from versioned path
    df = pd.read_csv(args.data_path)
    feature_cols = [c for c in df.columns if c != "target"]
    X = torch.tensor(df[feature_cols].values, dtype=torch.float32)
    y = torch.tensor(df["target"].values, dtype=torch.float32).unsqueeze(1)

    n_features = X.shape[1]
    model = nn.Sequential(
        nn.Linear(n_features, 8),
        nn.ReLU(),
        nn.Linear(8, 1),
    ).to(device)
    opt = torch.optim.Adam(model.parameters(), lr=args.lr)
    loss_fn = nn.MSELoss()

    # MLflow: one run per training job (params, metrics, model artifact)
    # https://mlflow.org/docs/latest/tracking.html
    mlflow.set_experiment("mlops-train")
    with mlflow.start_run():
        mlflow.log_params({
            "epochs": args.epochs,
            "lr": args.lr,
            "data_path": str(args.data_path),
            "n_features": n_features,
        })

        # Train
        X_dev, y_dev = X.to(device), y.to(device)
        for epoch in range(1, args.epochs + 1):
            model.train()
            opt.zero_grad()
            pred = model(X_dev)
            loss = loss_fn(pred, y_dev)
            loss.backward()
            opt.step()
            mlflow.log_metric("loss", loss.item(), step=epoch)
            if epoch % 10 == 0 or epoch == 1:
                print(f"epoch {epoch}\tloss {loss.item():.6f}")

        # Save to local dir (for scripts that expect models/model.pt)
        args.model_dir.mkdir(parents=True, exist_ok=True)
        out_path = args.model_dir / "model.pt"
        torch.save({"model_state_dict": model.state_dict(), "n_features": n_features}, out_path)
        print(f"Saved model to {out_path}")

        # Log model to MLflow and register it (creates a new version each run)
        # https://mlflow.org/docs/latest/python_api/mlflow.pytorch.html#mlflow.pytorch.log_model
        # https://mlflow.org/docs/latest/model-registry.html
        mlflow.pytorch.log_model(
            model,
            "model",
            input_example=X[:1].numpy(),
            registered_model_name="mlops-predictor",
        )


if __name__ == "__main__":
    main()
