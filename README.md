# Typhoon ASR Realtime API

FastAPI-based speech-to-text service using the Typhoon ASR model from SCB10X for real-time Thai speech recognition.

## Features

- 🎤 Speech-to-text transcription using Typhoon ASR Realtime model
- 🌐 RESTful API built with FastAPI
- 🐳 Dockerized for easy deployment
- 🔊 Supports multiple audio formats (mp3, wav, m4a, etc.) - automatically converted to 16kHz mono WAV
- 💡 Simple JSON response with transcription text and processing time
- 📖 Interactive API documentation at `/docs`

## Installation & Usage

### Option 1: Using Docker (Recommended)

1. **Build the Docker image:**
   ```bash
   docker build -t typhoon-asr-api .
   ```

2. **Run the container:**
   ```bash
   docker run -p 8000:8000 typhoon-asr-api
   ```

3. **Access the API:**
   - Swagger UI: http://localhost:8000/docs
   - API endpoint: http://localhost:8000/transcribe/

### Option 2: Direct Installation

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the application:**
   ```bash
   uvicorn app:app --host 0.0.0.0 --port 8000
   ```

## API Endpoints

### POST `/transcribe/`
Upload an audio file for transcription.

**Parameters:**
- `file`: Audio file (multipart/form-data)

**Returns:**
```json
{
  "filename": "original_filename.mp3",
  "text": "Transcribed Thai text",
  "processing_time": 0.123
}
```

## Model Information

This service uses the `scb10x/typhoon-asr-realtime` model from Hugging Face, which is optimized for Thai speech recognition.

## Notes

- The model automatically downloads on first run (approximately 1GB)
- Initial startup may take a moment while the model loads
- Audio files are converted to 16kHz mono WAV internally for optimal ASR performance
- Temporary files are automatically cleaned up after processing

## Example Usage with curl

```bash
curl -X POST "http://localhost:8000/transcribe/" \
     -F "file=@/path/to/your/audio.mp3"
```

## Troubleshooting

If you encounter issues:
1. Check container logs: `docker logs typhoon-asr`
2. Ensure sufficient memory (model requires ~2GB RAM)
3. Verify audio file is not corrupted
4. Check that port 8000 is available

## License

MIT