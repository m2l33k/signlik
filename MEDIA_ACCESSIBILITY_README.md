# Media & Accessibility Features

## Overview
This document describes the media storage and modality conversion features implemented in the SignLik backend.

## Features Implemented

### 1. File Storage (MinIO/S3)
- **Storage Service**: Handles file uploads to MinIO (S3-compatible storage)
- **Signed URLs**: Generates expiring URLs for secure file access
- **File Management**: Upload, download, and delete operations

### 2. Virus Scanning
- **VirusScanService**: Stub implementation ready for ClamAV integration
- **File Validation**: Basic file type and size validation
- **Security**: Scans files before storage

### 3. Modality Conversion Services

#### Speech-to-Text (STT)
- **Service**: `SpeechToTextService`
- **Status**: Stub implementation
- **Future Integration**: Google Cloud Speech-to-Text, AWS Transcribe, Azure Speech Services, OpenAI Whisper

#### Text-to-Speech (TTS)
- **Service**: `TextToSpeechService`
- **Status**: Stub implementation
- **Future Integration**: Google Cloud TTS, AWS Polly, Azure Cognitive Services

#### Sign Language to Text
- **Service**: `SignToTextService`
- **Status**: Stub implementation for future ML model integration
- **Future Integration**: Custom ML models, MediaPipe, third-party APIs

### 4. Background Job Processing
- **Async Processing**: Uses Spring's `@Async` for background jobs
- **Queue System**: Thread pool executor for conversion tasks
- **Status Tracking**: PENDING → PROCESSING → COMPLETED/FAILED

## Configuration

### MinIO Setup
1. Install MinIO: https://min.io/download
2. Start MinIO server:
   ```bash
   minio server ./data
   ```
3. Default credentials:
   - Access Key: `minioadmin`
   - Secret Key: `minioadmin`
   - Endpoint: `http://localhost:9000`

### Application Properties
```properties
storage.minio.endpoint=http://localhost:9000
storage.minio.access-key=minioadmin
storage.minio.secret-key=minioadmin
storage.minio.bucket-name=signlik-media
storage.url-expiration-seconds=3600
```

## API Endpoints

### File Management
- `POST /api/files/upload` - Upload file (multipart/form-data)
- `GET /api/files/download/{fileId}` - Download file
- `GET /api/files/url/{fileId}` - Get signed URL (expiring link)
- `DELETE /api/files/{fileId}` - Delete file

### Message with Attachments
When sending a VOICE or SIGN message with an `attachmentUrl`:
1. Message is saved with `conversionStatus: PENDING`
2. Background job is triggered automatically
3. Status updates: PROCESSING → COMPLETED (with transcript) or FAILED

## Workflow

### Voice Message Flow
1. User uploads audio file → `POST /api/files/upload`
2. File is scanned for viruses
3. File is stored in MinIO
4. User sends message with `type: VOICE` and `attachmentUrl`
5. Background job converts audio to text
6. Message is updated with transcript and `conversionStatus: COMPLETED`

### Sign Language Message Flow
1. User uploads video file → `POST /api/files/upload`
2. File is scanned for viruses
3. File is stored in MinIO
4. User sends message with `type: SIGN` and `attachmentUrl`
5. Background job converts sign language to text (future ML integration)
6. Message is updated with transcript and `conversionStatus: COMPLETED`

## Database Schema Updates

### MessageEntity
- `attachmentUrl` - URL to stored file
- `transcript` - Converted text from VOICE/SIGN messages
- `conversionStatus` - PENDING, PROCESSING, COMPLETED, FAILED

## Future Integrations

### ClamAV Virus Scanning
```java
// In VirusScanService.scanFile()
ClamAVClient client = new ClamAVClient("localhost", 3310);
byte[] reply = client.scan(file.getInputStream());
return ClamAVClient.isCleanReply(reply);
```

### Google Cloud Speech-to-Text
```java
// In SpeechToTextService.convertToText()
SpeechClient speechClient = SpeechClient.create();
RecognitionConfig config = RecognitionConfig.newBuilder()
    .setEncoding(RecognitionConfig.AudioEncoding.LINEAR16)
    .setLanguageCode("en-US")
    .build();
RecognizeResponse response = speechClient.recognize(config, audio);
return response.getResultsList().get(0).getAlternativesList().get(0).getTranscript();
```

### Sign Language ML Model
```java
// In SignToTextService.convertToText()
// 1. Load video file
// 2. Extract frames
// 3. Run through ML model (TensorFlow/PyTorch)
// 4. Convert gestures to text
// 5. Return transcript
```

## Testing

### Upload File
```bash
curl -X POST http://localhost:8081/api/files/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@audio.mp3" \
  -F "folder=voice"
```

### Send Voice Message
```json
POST /api/messages/send
{
  "content": "Voice message",
  "type": "VOICE",
  "attachmentUrl": "voice/abc123_audio.mp3",
  "sender": {...},
  "receiver": {...}
}
```

## Notes
- All file endpoints require JWT authentication
- Signed URLs expire after 1 hour (configurable)
- Conversion jobs run asynchronously in background
- Status can be checked by querying the message's `conversionStatus` field

