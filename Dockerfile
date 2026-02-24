# Training image: same code and deps as local, runs in a container.
# https://docs.docker.com/language/python/containerize/
FROM python:3.11-slim

WORKDIR /app

# Install dependencies as root (non-root cannot install packages).
# torch CPU-only first (~230MB vs ~1.5GB for the CUDA wheel). No GPU in this cluster.
COPY requirements.txt .
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu \
 && pip install --no-cache-dir -r requirements.txt

# Non-root user for production (Docker best practice).
RUN useradd --create-home --uid 1000 appuser
COPY --chown=appuser:appuser src ./src
COPY --chown=appuser:appuser data ./data
USER appuser

# Default: run training. Override with docker run ... --epochs 50
# Mount data, mlruns, and models so the container reads/writes host dirs.
CMD ["python", "-m", "src.train"]
