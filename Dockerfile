# FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime
FROM nvcr.io/nvidia/nemo:26.04


WORKDIR /app

# 1. Set environment variables to skip interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Bangkok

# 2. Install System Dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    build-essential \
    git \
    tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Python Dependencies
RUN pip install --no-cache-dir \
    fastapi uvicorn python-multipart \
    typhoon-asr \
    --ignore-installed PyYAML

# Force NeMo version to fix the "tdt_include_duration" error
# RUN pip install --no-cache-dir "nemo_toolkit[asr]"

COPY app.py /app/app.py

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
