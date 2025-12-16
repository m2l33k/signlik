# Sign Registration Feature

## Overview
This feature allows specialists to register new sign language signs by uploading videos or images. The system stores the sign data, manages approvals, and provides search capabilities.

## Features

### 1. Sign Registration
- **Specialist Role Required**: Only users with `SPECIALIST` role can add signs
- **File Upload**: Supports video (mp4, webm, mov, avi) and image (jpeg, png, gif, webp) files
- **Metadata**: Each sign includes:
  - Name (required, unique)
  - Description (optional)
  - Category (e.g., "greetings", "numbers", "actions")
  - Difficulty Level (beginner, intermediate, advanced)
  - Creator information
  - Approval status
  - View count

### 2. Sign Management
- **View Signs**: Public access to approved signs
- **Search**: Search signs by name or description
- **Categories**: Filter signs by category
- **Popular Signs**: Get most viewed signs
- **Recent Signs**: Get recently added signs
- **Update**: Sign creators can update their signs
- **Delete**: Sign creators or specialists can delete signs
- **Approval**: Specialists can approve signs for public viewing

### 3. Security & Validation
- **Virus Scanning**: All uploaded files are scanned
- **File Size Limit**: Maximum 100MB per file
- **Content Type Validation**: Only allowed video/image formats
- **Authorization**: Role-based access control
- **Approval System**: Signs require approval before public viewing

## API Endpoints

### Add Sign (POST /api/signs/add)
**Authentication**: Required (Specialist role)
**Request**: Multipart form data
- `file`: Video or image file (required)
- `name`: Sign name (required)
- `description`: Description (optional)
- `category`: Category (optional)
- `difficultyLevel`: Difficulty level (optional)

**Response**: SignResponse with sign details and signed URLs

### Get All Signs (GET /api/signs)
**Authentication**: Optional
**Query Parameters**:
- `includeUnapproved`: Include unapproved signs (specialist only)

**Response**: List of SignResponse objects

### Get Sign by ID (GET /api/signs/{id})
**Authentication**: Optional
**Response**: SignResponse object

### Search Signs (GET /api/signs/search?query=...)
**Authentication**: Not required
**Response**: List of matching signs

### Get Signs by Category (GET /api/signs/category/{category})
**Authentication**: Not required
**Response**: List of signs in category

### Get Signs by Specialist (GET /api/signs/specialist/{email})
**Authentication**: Not required
**Response**: List of signs created by specialist

### Get Popular Signs (GET /api/signs/popular?limit=10)
**Authentication**: Not required
**Response**: List of most viewed signs

### Get Recent Signs (GET /api/signs/recent?limit=10)
**Authentication**: Not required
**Response**: List of recently added signs

### Update Sign (PUT /api/signs/{id})
**Authentication**: Required (Creator or Specialist)
**Request Body**: SignRequest (JSON)
**Response**: Updated SignResponse

### Approve Sign (PUT /api/signs/{id}/approve)
**Authentication**: Required (Specialist role)
**Response**: Approved SignResponse

### Delete Sign (DELETE /api/signs/{id})
**Authentication**: Required (Creator or Specialist)
**Response**: Success message

## Database Schema

### Signs Table
- `id`: Primary key
- `name`: Sign name (unique, required)
- `description`: Description (optional)
- `video_url`: Storage path for video/image (required)
- `thumbnail_url`: Thumbnail image URL (optional)
- `created_by`: Email of specialist who created it (required)
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp
- `category`: Category classification
- `difficulty_level`: Difficulty level
- `is_approved`: Approval status (default: false)
- `view_count`: Number of views (default: 0)
- `file_size`: File size in bytes
- `duration_seconds`: Video duration (if available)
- `content_type`: MIME type of file

## Usage Flow

### For Specialists:

1. **Register as Specialist**:
   ```json
   POST /api/auth/register
   {
     "username": "sign_specialist",
     "email": "specialist@example.com",
     "password": "password123",
     "role": "SPECIALIST"
   }
   ```

2. **Login to Get JWT Token**:
   ```json
   POST /api/auth/login
   {
     "email": "specialist@example.com",
     "password": "password123"
   }
   ```

3. **Add a Sign**:
   - Use multipart/form-data
   - Upload video/image file
   - Provide sign name and optional metadata
   - Sign is created with `isApproved = false`

4. **Approve Signs** (if you're a specialist):
   - View unapproved signs: `GET /api/signs?includeUnapproved=true`
   - Approve: `PUT /api/signs/{id}/approve`

### For Regular Users:

1. **Browse Signs**:
   - View all approved signs: `GET /api/signs`
   - Search: `GET /api/signs/search?query=hello`
   - Filter by category: `GET /api/signs/category/greetings`
   - View popular: `GET /api/signs/popular?limit=10`

2. **View Sign Details**:
   - Get sign by ID: `GET /api/signs/{id}`
   - Automatically increments view count

## File Storage

- **Storage Service**: Uses MinIO (S3-compatible)
- **Folder Structure**: Files stored in `signs/` folder
- **Signed URLs**: Temporary expiring URLs for secure access
- **File Organization**: UUID-based file names to prevent conflicts

## Security Features

1. **Role-Based Access**:
   - Only SPECIALIST role can add signs
   - Only creators or specialists can update/delete
   - Only specialists can approve signs

2. **File Validation**:
   - Virus scanning before storage
   - File type validation
   - File size limits (100MB)

3. **Approval System**:
   - New signs require approval
   - Only approved signs visible to public
   - Specialists can view unapproved signs

## Frontend Integration

### Camera Integration Example (JavaScript):

```javascript
// Open camera and record video
async function recordSign() {
  const stream = await navigator.mediaDevices.getUserMedia({ 
    video: true, 
    audio: false 
  });
  
  const mediaRecorder = new MediaRecorder(stream);
  const chunks = [];
  
  mediaRecorder.ondataavailable = (e) => chunks.push(e.data);
  mediaRecorder.onstop = async () => {
    const blob = new Blob(chunks, { type: 'video/webm' });
    await uploadSign(blob);
  };
  
  mediaRecorder.start();
  // Stop after 5 seconds or on button click
  setTimeout(() => mediaRecorder.stop(), 5000);
}

// Upload sign to backend
async function uploadSign(videoBlob) {
  const formData = new FormData();
  formData.append('file', videoBlob, 'sign.webm');
  formData.append('name', document.getElementById('signName').value);
  formData.append('description', document.getElementById('description').value);
  formData.append('category', document.getElementById('category').value);
  formData.append('difficultyLevel', document.getElementById('difficulty').value);
  
  const response = await fetch('http://localhost:8081/api/signs/add', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${jwtToken}`
    },
    body: formData
  });
  
  const result = await response.json();
  console.log('Sign added:', result);
}
```

## Testing

See `http-requests.http` for complete API testing examples.

## Future Enhancements

1. **Thumbnail Generation**: Auto-generate thumbnails from videos
2. **Video Processing**: Extract duration, generate previews
3. **ML Integration**: Automatic sign recognition and classification
4. **Rating System**: Allow users to rate signs
5. **Comments**: Add comments/reviews for signs
6. **Collections**: Group related signs
7. **Sign Variations**: Link similar signs together
8. **Analytics**: Track sign usage and popularity

