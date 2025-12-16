# Testing Guide - Sign Registration Frontend

## Prerequisites

1. **Backend Server Running**: The Spring Boot backend must be running on `http://localhost:8081`
2. **MySQL Database**: MySQL must be running and connected
3. **Modern Browser**: Chrome, Edge, Firefox, or Safari (latest versions)

## Step-by-Step Testing

### Step 1: Start the Backend Server

#### Option A: Using IntelliJ IDEA
1. Open the project in IntelliJ IDEA
2. Find `BackendSignLikApplication.java`
3. Right-click → **Run 'BackendSignLikApplication'**
4. Wait for the server to start (look for "Started BackendSignLikApplication" in console)

#### Option B: Using Maven Command Line
```bash
cd signlik-backend/backendSignLik
./mvnw spring-boot:run
```

#### Option C: Using Maven Wrapper (Windows)
```powershell
cd signlik-backend\backendSignLik
.\mvnw.cmd spring-boot:run
```

**Verify Backend is Running:**
- Open browser and go to: `http://localhost:8081/swagger-ui.html`
- Or test: `http://localhost:8081/api/auth/register` (should return an error, not connection refused)

### Step 2: Open the Frontend Interface

#### Option A: Direct File Open (Easiest)
1. Navigate to: `signlik-backend/backendSignLik/frontend/`
2. Double-click `sign-registration.html`
3. It will open in your default browser

#### Option B: Using a Local Server (Recommended for Production)
If you get CORS errors or camera doesn't work, use a local server:

**Using Python:**
```bash
cd signlik-backend/backendSignLik/frontend
python -m http.server 8000
```
Then open: `http://localhost:8000/sign-registration.html`

**Using Node.js (http-server):**
```bash
npm install -g http-server
cd signlik-backend/backendSignLik/frontend
http-server -p 8000
```
Then open: `http://localhost:8000/sign-registration.html`

**Using VS Code Live Server:**
1. Install "Live Server" extension in VS Code
2. Right-click `sign-registration.html`
3. Select "Open with Live Server"

### Step 3: Test the Interface

#### 3.1 Register a Specialist Account
1. Click "Register as Specialist"
2. Fill in:
   - Username: `test_specialist`
   - Email: `specialist@test.com`
   - Password: `password123`
3. Click "Register"
4. You should see: "Registration successful! Please login."

#### 3.2 Login
1. Enter your email and password
2. Click "Login"
3. You should see the main interface with camera controls

#### 3.3 Test Camera
1. Click **"📹 Start Camera"**
2. Allow camera access when browser prompts
3. You should see your camera feed
4. Test buttons:
   - **"🔴 Start Recording"** - Records video
   - **"⏸️ Stop Recording"** - Stops and shows preview
   - **"📸 Capture Photo"** - Takes a photo

#### 3.4 Register a Sign
1. Record a video or capture a photo (or upload a file)
2. Fill in the form:
   - Sign Name: `Hello` (required)
   - Description: `A greeting sign`
   - Category: `greetings`
   - Difficulty: `beginner`
3. Click **"✅ Register Sign"**
4. You should see: "Sign registered successfully!"

#### 3.5 Browse Signs
1. Click **"Load Recent"** to see recent signs
2. Use **Search** to find signs
3. Filter by **Category**
4. Click **"Load My Signs"** to see your registered signs

## Troubleshooting

### Issue: "Connection Refused" Error

**Problem**: Backend server is not running

**Solution**:
1. Check if backend is running:
   ```bash
   # Check if port 8081 is in use
   netstat -an | findstr 8081
   ```
2. Start the backend server (see Step 1)
3. Wait for "Started BackendSignLikApplication" message
4. Try accessing `http://localhost:8081/swagger-ui.html` to verify

### Issue: "Access Denied" MySQL Error

**Problem**: MySQL connection failed

**Solution**:
1. Check MySQL is running
2. Update `application.properties` with correct MySQL credentials:
   ```properties
   spring.datasource.username=root
   spring.datasource.password=your_password
   ```
3. See `MYSQL_SETUP.md` for detailed MySQL setup

### Issue: Camera Not Working

**Problem**: Browser can't access camera

**Solutions**:
1. **Use HTTPS or localhost**: Camera requires secure context
2. **Check browser permissions**: Allow camera access
3. **Try different browser**: Chrome/Edge work best
4. **Check camera is not in use**: Close other apps using camera

### Issue: CORS Errors

**Problem**: Cross-Origin Resource Sharing blocked

**Solution**:
1. Make sure backend CORS is configured (already done in `CorsConfig.java`)
2. Use a local server instead of file:// protocol
3. Check browser console for specific CORS errors

### Issue: "Only specialists can add signs"

**Problem**: User role is not SPECIALIST

**Solution**:
1. Make sure you registered with `role: "SPECIALIST"`
2. Check your JWT token contains the correct role
3. Re-register if needed

### Issue: File Upload Fails

**Problem**: File too large or wrong format

**Solution**:
1. Check file size (max 100MB)
2. Use supported formats: MP4, WebM, MOV, AVI, JPEG, PNG, GIF, WebP
3. Check browser console for error messages

## Quick Test Checklist

- [ ] Backend server running on port 8081
- [ ] MySQL database connected
- [ ] Frontend HTML file opens in browser
- [ ] Can register specialist account
- [ ] Can login successfully
- [ ] Camera starts and shows preview
- [ ] Can record video or capture photo
- [ ] Can fill sign registration form
- [ ] Can submit sign successfully
- [ ] Can browse/search signs
- [ ] Can view own signs

## Testing Different Scenarios

### Test 1: Video Recording
1. Start camera
2. Record a 5-second video
3. Stop recording
4. Fill form and submit
5. Verify sign appears in "My Signs"

### Test 2: Photo Capture
1. Start camera
2. Capture a photo
3. Fill form and submit
4. Verify sign appears

### Test 3: File Upload
1. Click "Or Upload File"
2. Select a video/image file
3. Fill form and submit
4. Verify sign appears

### Test 4: Search Functionality
1. Register multiple signs with different names
2. Use search to find specific signs
3. Verify results are correct

### Test 5: Category Filter
1. Register signs in different categories
2. Use category filter
3. Verify only signs in that category appear

### Test 6: Approval System
1. Register a sign (should be unapproved)
2. As specialist, approve the sign
3. Verify sign shows as "Approved"

## Browser Console

Open browser developer tools (F12) to see:
- API requests/responses
- JavaScript errors
- Network activity
- Console logs

## API Testing Alternative

If frontend doesn't work, test API directly using:
- `http-requests.http` file in IntelliJ IDEA
- Postman
- Swagger UI: `http://localhost:8081/swagger-ui.html`

## Next Steps

Once testing is successful:
1. Customize the interface for your needs
2. Integrate into your main frontend application
3. Deploy to production (use HTTPS for camera)

