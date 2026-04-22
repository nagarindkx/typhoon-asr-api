# ใช้ Python 3.10 เป็น Base Image
FROM python:3.10-slim

# ตั้งค่า Working Directory
WORKDIR /app

# ติดตั้ง System Dependencies ที่จำเป็นสำหรับการประมวลผลไฟล์เสียง
RUN apt-get update && apt-get install -y \
    libsndfile1 \
    ffmpeg \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# รวบคำสั่ง pip install ไว้ด้วยกัน และใช้ --extra-index-url 
# เพื่อให้ pip จัดการ Dependency ของ torch, torchaudio และ typhoon-asr ให้ตรงกันทั้งหมด
# RUN pip install --no-cache-dir \
#     torch torchaudio \
#     typhoon-asr fastapi uvicorn python-multipart \
#     --extra-index-url https://download.pytorch.org/whl/cu121

# รวบคำสั่ง pip install ไว้ด้วยกัน และล็อคเวอร์ชัน nemo_toolkit ไว้ไม่ให้เกิน 2.0.0
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