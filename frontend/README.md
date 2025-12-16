# Sign Registration Frontend

A complete, ready-to-use frontend interface for the Sign Registration feature.

## Files

- `sign-registration.html` - Main HTML structure
- `sign-registration.css` - Styling and responsive design
- `sign-registration.js` - JavaScript functionality

## Features

### 1. Authentication
- Login/Register as Specialist
- JWT token management
- Auto-login from localStorage

### 2. Camera Interface
- Start/Stop camera
- Record video (WebM format)
- Capture photo
- Preview recorded media
- Upload file alternative

### 3. Sign Registration
- Form with validation
- File upload (video/image)
- Category and difficulty selection
- Real-time form validation

### 4. Sign Management
- View all signs
- Search signs
- Filter by category
- View popular/recent signs
- View your own signs
- Approve/Delete signs (specialist only)

## Setup

### Option 1: Standalone (Quick Test)

1. Open `sign-registration.html` in a web browser
2. Make sure your backend is running on `http://localhost:8081`
3. Register a specialist account or login
4. Start using the interface!

### Option 2: Integration with Your Frontend

#### Step 1: Copy Files
Copy the three files to your frontend project:
```
your-frontend/
  ├── sign-registration.html
  ├── sign-registration.css
  └── sign-registration.js
```

#### Step 2: Update API URL
In `sign-registration.js`, update the API base URL:
```javascript
const API_BASE_URL = 'http://your-backend-url/api';
// Or use environment variable:
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8081/api';
```

#### Step 3: Include in Your App

**If using React:**
```jsx
// Create a component wrapper
import './sign-registration.css';
import './sign-registration.js';

function SignRegistration() {
  return (
    <div>
      <iframe 
        src="/sign-registration.html" 
        style={{ width: '100%', height: '100vh', border: 'none' }}
        title="Sign Registration"
      />
    </div>
  );
}
```

**If using Vue:**
```vue
<template>
  <div>
    <iframe 
      src="/sign-registration.html" 
      style="width: 100%; height: 100vh; border: none;"
    />
  </div>
</template>
```

**If using Angular:**
```typescript
// In your component
@Component({
  selector: 'app-sign-registration',
  template: `
    <iframe 
      src="/assets/sign-registration.html" 
      style="width: 100%; height: 100vh; border: none;"
    ></iframe>
  `
})
```

**If using plain HTML/JS:**
```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="sign-registration.css">
</head>
<body>
  <!-- Your existing content -->
  
  <!-- Include sign registration -->
  <div id="sign-registration-container"></div>
  
  <script src="sign-registration.js"></script>
  <script>
    // Load the HTML content
    fetch('sign-registration.html')
      .then(r => r.text())
      .then(html => {
        document.getElementById('sign-registration-container').innerHTML = html;
      });
  </script>
</body>
</html>
```

#### Step 4: Modular Integration (Recommended)

Extract the functionality into reusable functions:

```javascript
// sign-registration-module.js
export class SignRegistrationModule {
  constructor(apiBaseUrl, containerId) {
    this.API_BASE_URL = apiBaseUrl;
    this.container = document.getElementById(containerId);
    this.currentUser = this.loadUser();
  }

  loadUser() {
    return {
      email: localStorage.getItem('user_email'),
      token: localStorage.getItem('jwt_token'),
      role: localStorage.getItem('user_role')
    };
  }

  async addSign(file, name, description, category, difficultyLevel) {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('name', name);
    formData.append('description', description);
    formData.append('category', category);
    formData.append('difficultyLevel', difficultyLevel);

    const response = await fetch(`${this.API_BASE_URL}/signs/add`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.currentUser.token}`
      },
      body: formData
    });

    return await response.json();
  }

  async getSigns() {
    const response = await fetch(`${this.API_BASE_URL}/signs`);
    return await response.json();
  }

  // ... more methods
}

// Usage in your app
const signModule = new SignRegistrationModule('http://localhost:8081/api', 'my-container');
```

## API Integration

The frontend uses these endpoints:

- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Register
- `POST /api/signs/add` - Add sign (multipart/form-data)
- `GET /api/signs` - Get all signs
- `GET /api/signs/{id}` - Get sign by ID
- `GET /api/signs/search?query=...` - Search signs
- `GET /api/signs/category/{category}` - Get by category
- `GET /api/signs/popular?limit=10` - Popular signs
- `GET /api/signs/recent?limit=10` - Recent signs
- `GET /api/signs/specialist/{email}` - Get specialist's signs
- `PUT /api/signs/{id}` - Update sign
- `PUT /api/signs/{id}/approve` - Approve sign
- `DELETE /api/signs/{id}` - Delete sign

## Browser Compatibility

- **Chrome/Edge**: Full support (recommended)
- **Firefox**: Full support
- **Safari**: Full support (iOS 11+)
- **Opera**: Full support

## Camera Permissions

The browser will ask for camera permission when you click "Start Camera". Make sure to:
- Allow camera access when prompted
- Use HTTPS in production (required for camera access)
- Test on a device with a camera

## File Formats Supported

- **Video**: MP4, WebM, MOV, AVI
- **Image**: JPEG, PNG, GIF, WebP
- **Max Size**: 100MB

## Customization

### Change Colors
Edit `sign-registration.css`:
```css
.btn-primary {
    background: #your-color; /* Change primary color */
}
```

### Change API URL
Edit `sign-registration.js`:
```javascript
const API_BASE_URL = 'http://your-api-url/api';
```

### Add More Categories
Edit `sign-registration.html`:
```html
<option value="your-category">Your Category</option>
```

## Troubleshooting

### Camera not working?
- Check browser permissions
- Use HTTPS in production
- Try a different browser

### API errors?
- Check backend is running
- Verify API URL is correct
- Check CORS settings in backend

### File upload fails?
- Check file size (max 100MB)
- Verify file format is supported
- Check backend storage service is running

## Production Deployment

1. **Update API URL** to production backend
2. **Enable HTTPS** (required for camera)
3. **Minify CSS/JS** for performance
4. **Add error tracking** (e.g., Sentry)
5. **Test on mobile devices**

## Support

For issues or questions, check:
- Backend API documentation
- Browser console for errors
- Network tab for API requests

