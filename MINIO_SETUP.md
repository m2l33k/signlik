# MinIO Setup Guide

## Problem
You're getting **500 Internal Server Error** when trying to upload signs because MinIO (file storage) is not running.

## What is MinIO?
MinIO is an S3-compatible object storage service used to store uploaded files (videos/images).

## Quick Setup

### Option 1: Install and Run MinIO (Recommended)

#### Windows:
1. **Download MinIO**: https://min.io/download
2. **Extract** the `minio.exe` file
3. **Run MinIO**:
   ```powershell
   .\minio.exe server C:\minio-data
   ```
4. **Access MinIO Console**: http://localhost:9001
   - Username: `minioadmin`
   - Password: `minioadmin`

#### Using Docker (Easiest):
```bash
docker run -d -p 9000:9000 -p 9001:9001 --name minio \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin" \
  minio/minio server /data --console-address ":9001"
```

Then access: http://localhost:9001

### Option 2: Make MinIO Optional (For Testing)

If you just want to test without MinIO, I can modify the code to store files locally temporarily. But for production, MinIO is recommended.

## Verify MinIO is Running

1. Open browser: http://localhost:9000
2. You should see MinIO status page
3. Or check: http://localhost:9001 (Console)

## After Starting MinIO

1. **Restart your backend** (if it's running)
2. **Try uploading a sign again** in the frontend
3. It should work now! ✅

## Configuration

MinIO is already configured in `application.properties`:
```properties
storage.minio.endpoint=http://localhost:9000
storage.minio.access-key=minioadmin
storage.minio.secret-key=minioadmin
storage.minio.bucket-name=signlik-media
```

The bucket will be created automatically when you upload the first file.

## Troubleshooting

### Port 9000 already in use?
- Change MinIO port: `minio server --address :9002 ./data`
- Update `application.properties`: `storage.minio.endpoint=http://localhost:9002`

### Can't connect to MinIO?
- Check MinIO is running
- Check firewall isn't blocking port 9000
- Verify credentials match in `application.properties`

## Quick Test

After starting MinIO, test the connection:
```bash
curl http://localhost:9000/minio/health/live
```

Should return: `OK`

