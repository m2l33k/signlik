# Local File Storage Guide

## Overview

The backend now supports **two storage modes**:
1. **Local Storage** (for testing without MinIO)
2. **MinIO Storage** (for production)

## Quick Start (Local Storage)

### Step 1: Configure Local Storage

In `application.properties`, set:
```properties
storage.type=local
```

### Step 2: Restart Backend

Restart your Spring Boot application. The `uploads` directory will be created automatically.

### Step 3: Test File Upload

Upload a sign using the frontend or Postman. Files will be stored in:
```
./uploads/signs/
```

### Step 4: Access Files

Files are accessible via:
```
http://localhost:8081/api/files/local/signs/{filename}
```

## Configuration

### Local Storage Settings

```properties
# Storage Configuration
storage.type=local

# Local File Storage Configuration
storage.local.base-path=./uploads
storage.local.base-url=http://localhost:8081/api/files/local
```

### MinIO Storage Settings

```properties
# Storage Configuration
storage.type=minio

# MinIO/S3 Storage Configuration
storage.minio.endpoint=http://localhost:9000
storage.minio.access-key=minioadmin
storage.minio.secret-key=minioadmin
storage.minio.bucket-name=signlik-media
storage.url-expiration-seconds=3600
```

## Switching Between Storage Types

### To Use Local Storage:
1. Set `storage.type=local` in `application.properties`
2. Restart backend
3. No MinIO required! ✅

### To Use MinIO:
1. Set `storage.type=minio` in `application.properties`
2. Start MinIO server
3. Restart backend

## File Structure (Local Storage)

```
uploads/
├── signs/
│   ├── abc123_video1.mp4
│   ├── def456_video2.webm
│   └── ...
├── voice/
│   └── ...
└── general/
    └── ...
```

## Benefits of Local Storage

✅ **No external dependencies** - Works without MinIO  
✅ **Easy testing** - Perfect for development  
✅ **Fast setup** - No configuration needed  
✅ **Direct file access** - Files served directly by Spring Boot  

## Production Recommendation

For production, use **MinIO** (`storage.type=minio`) because:
- Better scalability
- S3-compatible API
- Better for distributed systems
- Presigned URLs with expiration

## Troubleshooting

### Files not accessible?
- Check that `storage.type=local` is set
- Verify the `uploads` directory exists
- Check file permissions

### Still getting MinIO errors?
- Make sure `storage.type=local` is set
- Restart the backend after changing configuration
- Check that MinioClient bean is not being created (it's conditional)

### File upload fails?
- Check disk space
- Verify write permissions on `uploads` directory
- Check file size limits in `application.properties`

## API Endpoints

### Upload File
```
POST /api/files/upload
Content-Type: multipart/form-data
Authorization: Bearer {token}

file: {file}
folder: signs
```

### Access Local File
```
GET /api/files/local/signs/{filename}
(No authentication required)
```

### Get Signed URL (Local Storage)
```
GET /api/files/url/{fileId}
Authorization: Bearer {token}

Returns: http://localhost:8081/api/files/local/{fileId}
```

## Notes

- Local storage files are stored in the `uploads` directory (relative to the application root)
- Files are organized by folder (e.g., `signs/`, `voice/`, `general/`)
- The `uploads` directory is created automatically on first upload
- Local files are publicly accessible (no authentication required for `/api/files/local/**`)

