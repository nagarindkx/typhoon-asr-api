# ใช้ Python 3.10 เป็น Base Image
FROM python:3.10-slim

# ตั้งค่า Working Directory
WORKDIR /app

# 1. ติดตั้ง System Dependencies (คงไว้ตามเดิม)
RUN apt-get update && apt-get install -y \
    libsndfile1 \
    ffmpeg \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2. ต้องติดตั้ง Cython และ build tools ก่อนเป็นอันดับแรก 
# เพราะ sub-dependency (youtokentome) จำเป็นต้องใช้ในการ compile
RUN pip install --no-cache-dir Cython setuptools wheel

# 3. ติดตั้งแพ็กเกจหลัก (รวมที่แก้เรื่อง Version Mismatch จากครั้งก่อนด้วย)
RUN pip install --no-cache-dir \
    torch torchaudio \
    "nemo_toolkit[asr]<2.0.0" \
    typhoon-asr fastapi uvicorn python-multipart \
    --extra-index-url https://download.pytorch.org/whl/cu121
# คัดลอกโค้ด API ของเราเข้าไปใน Container
COPY app.py /app/app.py

# เปิด Port 8000
EXPOSE 8000

# รัน FastAPI Server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]