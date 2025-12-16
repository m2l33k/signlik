# Start Frontend - Quick Guide

## ✅ Backend is Running!
Your backend is successfully running on `http://localhost:8081`

## 🚀 Open Frontend (Choose One Method)

### Method 1: Direct File Open (Easiest - No Server Needed)
1. Open File Explorer
2. Navigate to: `C:\Users\ayoub\IdeaProjects\signlink\signlik-backend\backendSignLik\frontend\`
3. **Double-click** `sign-registration.html`
4. It will open in your default browser
5. **Done!** ✅

### Method 2: Using Python HTTP Server (If Method 1 has CORS issues)
1. Open PowerShell or Command Prompt
2. Run:
   ```powershell
   cd C:\Users\ayoub\IdeaProjects\signlink\signlik-backend\backendSignLik\frontend
   python -m http.server 8000
   ```
3. Open browser: `http://localhost:8000/sign-registration.html`

### Method 3: Using VS Code Live Server
1. Install "Live Server" extension in VS Code
2. Right-click `sign-registration.html`
3. Click "Open with Live Server"

## 🧪 Test Steps

1. **Register Specialist**:
   - Click "Register as Specialist"
   - Username: `test_specialist`
   - Email: `specialist@test.com`
   - Password: `password123`
   - Click "Register"

2. **Login**:
   - Enter email and password
   - Click "Login"

3. **Start Camera**:
   - Click "📹 Start Camera"
   - Allow camera access when prompted

4. **Record Sign**:
   - Click "🔴 Start Recording"
   - Make a sign with your hand
   - Click "⏸️ Stop Recording"

5. **Register Sign**:
   - Sign Name: `Hello` (required)
   - Description: `A greeting sign`
   - Category: `greetings`
   - Difficulty: `beginner`
   - Click "✅ Register Sign"

6. **Browse Signs**:
   - Click "Load Recent" to see your sign
   - Use search to find signs
   - Click "Load My Signs" to see all your signs

## ⚠️ Troubleshooting

### If you see "Connection Refused" on port 8000:
- **You don't need port 8000!** Just double-click the HTML file directly
- Port 8000 is only needed if you want to run a local server

### If camera doesn't work:
- Use Chrome or Edge browser
- Allow camera permissions
- Make sure no other app is using the camera

### If you see API errors:
- Make sure backend is still running (check IntelliJ console)
- Verify backend URL in browser console (F12)

## ✅ Success Indicators

- Backend running: `http://localhost:8081/swagger-ui.html` works
- Frontend opens: You see the sign registration interface
- Can login: Login form accepts credentials
- Camera works: Video preview appears

