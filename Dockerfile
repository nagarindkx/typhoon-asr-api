# ใช้ Python 3.10 เป็น Base Image
FROM python:3.10-slim

# ตั้งค่า Working Directory
WORKDIR /app

# ติดตั้ง System Dependencies ที่จำเป็นสำหรับการประมวลผลไฟล์เสียง (soundfile, librosa)
RUN apt-get update && apt-get install -y \
    libsndfile1 \
    ffmpeg \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ติดตั้ง PyTorch (เวอร์ชัน CPU) - โมเดลนี้ถูก Optimize มาให้รันบน CPU ได้ดีมาก
# หากต้องการใช้ GPU ให้เปลี่ยน URL เป็นของ CUDA
RUN pip install --no-cache-dir torch torchaudio --index-url https://download.pytorch.org/whl/cpu

# ติดตั้ง Typhoon ASR และ FastAPI สำหรับทำ API Server
RUN pip install --no-cache-dir typhoon-asr fastapi uvicorn python-multipart

# คัดลอกโค้ด API ของเราเข้าไปใน Container
COPY app.py /app/app.py

# เปิด Port 8000
EXPOSE 8000

# รัน FastAPI Server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
