# Use the official PyTorch image (2.2.0 with Python 3.10)
FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-runtime

# Set Working Directory
WORKDIR /app

# 1. Install System Dependencies
# Note: ffmpeg is still needed for audio processing
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Python Dependencies
# We skip reinstalling torch since it's already in the base image
RUN pip install --no-cache-dir typhoon-asr fastapi uvicorn python-multipart ffmpeg-python

COPY app.py /app/app.py

# Open Port 8000
EXPOSE 8000

# Run FastAPI Server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
