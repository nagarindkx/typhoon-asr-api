# Use the PyTorch runtime as it's more flexible for versioning
FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime

WORKDIR /app

# 1. Install System Dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg build-essential git \
    && rm -rf /var/lib/apt/lists/*

# 2. Install specific versions to avoid the 'tdt_include_duration' error
# We install typhoon-asr first, then force a NeMo version that is compatible
RUN pip install --no-cache-dir \
    fastapi uvicorn python-multipart ffmpeg-python \
    typhoon-asr

# Force downgrade/upgrade NeMo to a stable version 
# 1.22.0 is generally stable for these model types
RUN pip install --no-cache-dir "nemo_toolkit[asr]==1.22.0"

COPY app.py /app/app.py

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
