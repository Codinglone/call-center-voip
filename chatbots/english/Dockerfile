FROM python:3.11-slim-bookworm

WORKDIR /app

# Install system dependencies
# ffmpeg removed: we read WAV via soundfile (numpy) and pass arrays directly
# to faster-whisper, so no ffmpeg CLI is needed.
RUN apt-get update && apt-get install -y \
    curl \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Install torch CPU wheel first (heavy, cache-friendly layer)
RUN pip install --no-cache-dir --default-timeout=300 torch==2.1.2 --index-url https://download.pytorch.org/whl/cpu

# Copy requirements and install remaining Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --default-timeout=300 -r requirements.txt

# Copy application code
COPY src/main.py ./src/main.py
COPY src/download_models.py ./src/download_models.py

# Note: models are downloaded on first container start (lazy loading)
# To pre-download at build time, uncomment the line below (adds ~1.2 GB):
# RUN python ./src/download_models.py

# Expose port
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# Run application
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8001"]
