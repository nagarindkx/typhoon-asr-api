from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from typhoon_asr import transcribe
import shutil
import os
import subprocess

app = FastAPI(title="Typhoon ASR Realtime API")

def convert_to_wav(input_path, output_path):
    """ใช้ ffmpeg แปลงไฟล์เสียงทุกประเภทเป็น WAV (16kHz, Mono) ที่เหมาะกับ ASR"""
    command = [
        "ffmpeg",
        "-y",             # เขียนทับไฟล์ปลายทางถ้ามี
        "-i", input_path, # ไฟล์ต้นฉบับ
        "-ar", "16000",   # Sample rate 16000 Hz (มาตรฐาน ASR)
        "-ac", "1",       # 1 Channel (Mono)
        output_path
    ]
    # รันคำสั่ง (ซ่อน log ของ ffmpeg ไว้จะได้ไม่รก console)
    subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

@app.post("/transcribe/")
async def transcribe_audio(file: UploadFile = File(...)):
    # สร้างชื่อไฟล์ชั่วคราว 2 ไฟล์ (ต้นฉบับ และ ไฟล์ที่แปลงแล้ว)
    original_temp = f"temp_orig_{file.filename}"
    wav_temp = f"temp_wav_{file.filename}.wav"
    
    # 1. บันทึกไฟล์ที่อัปโหลดมา (.m4a, .mp3, etc.)
    with open(original_temp, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    try:
        # 2. แปลงไฟล์เป็น .wav ด้วยฟังก์ชันที่เราสร้างไว้
        convert_to_wav(original_temp, wav_temp)
        
        # ตรวจสอบว่าแปลงไฟล์สำเร็จหรือไม่
        if not os.path.exists(wav_temp):
            raise Exception("ไม่สามารถแปลงไฟล์เสียงได้ กรุณาตรวจสอบว่าไฟล์เสียงถูกต้องหรือไม่")

        # 3. เรียกใช้งานโมเดล โดยส่งไฟล์ .wav ที่แปลงเสร็จแล้วไปให้
        result = transcribe(wav_temp, device="cuda", with_timestamps=False)
        
        # --- จัดการดึงข้อความ ---
        raw_text = result.get('text', '')
        if isinstance(raw_text, list):
            extracted_text = " ".join([getattr(item, "text", str(item)) for item in raw_text])
        elif hasattr(raw_text, "text"):
            extracted_text = raw_text.text
        else:
            extracted_text = str(raw_text)
        
        return JSONResponse(content={
            "filename": file.filename,
            "text": extracted_text,
            "processing_time": result.get('processing_time', 0)
        })
        
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})
    finally:
        # 4. ลบไฟล์ชั่วคราวทิ้งทั้งสองไฟล์หลังใช้งานเสร็จ
        if os.path.exists(original_temp):
            os.remove(original_temp)
        if os.path.exists(wav_temp):
            os.remove(wav_temp)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
