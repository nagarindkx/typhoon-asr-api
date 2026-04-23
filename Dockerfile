# ใช้ Python 3.10 เป็น Base Image
FROM python:3.10-slim

# ตั้งค่า Working Directory
WORKDIR /app

# 1. ติดตั้ง System Dependencies (คงไว้ตามเดิม)
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. ติดตั้ง Python Dependencies (คงไว้ตามเดิม)
RUN pip install typhoon-asr fastapi uvicorn python-multipart

COPY app.py /app/app.py

# เปิด Port 8000
EXPOSE 8000

# รัน FastAPI Server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]