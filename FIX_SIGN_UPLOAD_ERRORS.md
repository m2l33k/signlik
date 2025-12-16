# Fix Sign Upload Errors

## Issues Found

1. **500 Internal Server Error** - MinIO not running
2. **400 Bad Request** - Validation errors
3. **403 Forbidden** - Security configuration issue
4. **JSON Parse Error** - Error response format issue

## Fixes Applied

### 1. Error Response Format ✅
- Created `ErrorResponse` DTO for proper JSON error responses
- Updated all error handlers to return JSON instead of plain text
- Frontend now properly parses error messages

### 2. Security Configuration ✅
- Fixed `/api/signs/specialist/{email}` endpoint to be publicly accessible
- Updated security rules to allow viewing signs by specialist

### 3. MinIO Error Handling ✅
- Improved error messages when MinIO is not available
- Better exception handling in StorageService

### 4. Frontend Error Handling ✅
- Updated JavaScript to handle JSON error responses
- Better error message display

## Next Steps

### Step 1: Fix Role Column (If Not Done)
Run this SQL in MySQL:
```sql
USE signlikdb;
ALTER TABLE users MODIFY COLUMN role VARCHAR(20) NOT NULL;
```

### Step 2: Start MinIO (Required for File Upload)

**Option A: Using Docker (Easiest)**
```bash
docker run -d -p 9000:9000 -p 9001:9001 --name minio \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin" \
  minio/minio server /data --console-address ":9001"
```

**Option B: Download and Run**
1. Download: https://min.io/download
2. Run: `minio server ./data`
3. Access console: http://localhost:9001

### Step 3: Restart Backend
- Stop current backend
- Restart in IntelliJ IDEA
- Wait for "Started BackendSignLikApplication"

### Step 4: Test Again
1. Refresh frontend page
2. Login as specialist
3. Try uploading a sign
4. Should work now! ✅

## Error Messages You'll See

### If MinIO Not Running:
```
Error: Failed to upload file to storage. MinIO may not be running.
```

**Solution**: Start MinIO (see Step 2)

### If Sign Name Already Exists:
```
Error: A sign with this name already exists
```

**Solution**: Use a different sign name

### If File Too Large:
```
Error: File size exceeds maximum allowed size (100MB)
```

**Solution**: Use a smaller file

### If Invalid File Type:
```
Error: Invalid file type. Allowed types: video (mp4, webm, mov, avi) or image (jpeg, png, gif, webp)
```

**Solution**: Use a supported file format

## Testing Without MinIO (Temporary)

If you want to test without MinIO, I can modify the code to:
- Store files temporarily in a local folder
- Skip MinIO for development
- Add a flag to enable/disable MinIO

Let me know if you want this option!

