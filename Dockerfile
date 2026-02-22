# Training image: same code and deps as local, runs in a container.
# https://docs.docker.com/language/python/containerize/
FROM python:3.11-slim

WORKDIR /app

# Install dependencies as root (non-root cannot install packages).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Non-root user for production (Docker best practice).
RUN useradd --create-home --uid 1000 appuser
COPY --chown=appuser:appuser src ./src
USER appuser

# Default: run training. Override with docker run ... --epochs 50
# Mount data, mlruns, and models so the container reads/writes host dirs.
CMD ["python", "-m", "src.train"]
