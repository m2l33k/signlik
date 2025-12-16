# Quick Start - Test Frontend Interface

## Step 1: Start Backend Server

### In IntelliJ IDEA:
1. Open `BackendSignLikApplication.java`
2. Right-click → **Run 'BackendSignLikApplication'**
3. Wait for: `Started BackendSignLikApplication` in console

### Or using Maven:
```bash
cd signlik-backend\backendSignLik
.\mvnw.cmd spring-boot:run
```

**⚠️ Important**: Make sure MySQL is running and credentials are correct in `application.properties`

## Step 2: Verify Backend is Running

Open in browser: `http://localhost:8081/swagger-ui.html`

If you see Swagger UI, backend is running! ✅

## Step 3: Open Frontend

### Option A: Direct (Easiest)
1. Go to: `signlik-backend\backendSignLik\frontend\`
2. Double-click `sign-registration.html`
3. Opens in your browser

### Option B: With Local Server (Better for camera)
```bash
cd signlik-backend\backendSignLik\frontend
python -m http.server 8000
```
Then open: `http://localhost:8000/sign-registration.html`

## Step 4: Test

1. **Register**: Click "Register as Specialist"
2. **Login**: Use your credentials
3. **Start Camera**: Click "📹 Start Camera"
4. **Record**: Click "🔴 Start Recording" then "⏸️ Stop Recording"
5. **Fill Form**: Enter sign name, description, etc.
6. **Submit**: Click "✅ Register Sign"

Done! 🎉

