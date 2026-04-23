# Use the NeMo image which has all ASR dependencies pre-installed
FROM nvcr.io/nvidia/nemo:24.01.framework

# Set Working Directory
WORKDIR /app

# 1. Install System Dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Python Dependencies
# We only install the API wrappers and typhoon-asr
RUN pip install --no-cache-dir typhoon-asr fastapi uvicorn python-multipart ffmpeg-python

COPY app.py /app/app.py

# Open Port 8000
EXPOSE 8000

# Run FastAPI Server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
