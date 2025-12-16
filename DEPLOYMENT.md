# Deployment Guide

This guide covers deploying the Gesture AI mobile application and backend.

## Backend Deployment (NestJS)

### Option 1: Render

1. **Create a Render Account**
   - Sign up at https://render.com

2. **Create PostgreSQL Database**
   - New → PostgreSQL
   - Name: `gesture-ai-db`
   - Note the connection details

3. **Deploy Backend Service**
   - New → Web Service
   - Connect your GitHub repository
   - Select the `backend` directory
   - Build Command: `npm install && npm run build`
   - Start Command: `npm run start:prod`
   - Environment Variables:
     - `NODE_ENV=production`
     - `PORT=10000`
     - `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME` (from PostgreSQL)
     - `DB_SSL=true`
     - `JWT_SECRET` (generate a secure random string)

4. **Deploy**
   - Click "Create Web Service"
   - Wait for deployment to complete
   - Note the service URL (e.g., `https://gesture-ai-backend.onrender.com`)

### Option 2: Vercel

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Deploy**
   ```bash
   cd backend
   vercel
   ```

3. **Set Environment Variables**
   - Go to Vercel Dashboard → Project → Settings → Environment Variables
   - Add all required variables (same as Render)

### Option 3: Railway

1. **Create Railway Account**
   - Sign up at https://railway.app

2. **New Project → Deploy from GitHub**
   - Select repository
   - Add PostgreSQL service
   - Add Node.js service (point to `backend` directory)

3. **Configure Environment Variables**
   - Same as Render configuration

## Mobile App Deployment

### Android

1. **Build APK**
   ```bash
   cd mobile
   flutter build apk --release
   ```

2. **Build App Bundle (for Play Store)**
   ```bash
   flutter build appbundle --release
   ```

3. **Update API Base URL**
   - Edit `mobile/lib/services/api_service.dart`
   - Change `baseUrl` to your deployed backend URL

4. **Test on Device**
   ```bash
   flutter install
   ```

### iOS

1. **Build IPA**
   ```bash
   cd mobile
   flutter build ios --release
   ```

2. **Open Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Configure Signing**
   - Select your development team
   - Set bundle identifier

4. **Archive and Upload**
   - Product → Archive
   - Distribute App → App Store Connect

## Environment Setup

### Backend `.env` File

Create `backend/.env`:

```env
DB_HOST=your-db-host
DB_PORT=5432
DB_USERNAME=your-username
DB_PASSWORD=your-password
DB_NAME=gesture_ai
DB_SSL=true
JWT_SECRET=your-secret-key
PORT=3000
NODE_ENV=production
```

### Flutter Configuration

Update `mobile/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-backend-url.com';
```

## Model Deployment

1. **Train the Model**
   ```bash
   cd ml
   python train_landmark_model.py
   ```

2. **Convert to TFLite**
   ```bash
   python convert_to_tflite.py
   ```

3. **Copy to Flutter Assets**
   ```bash
   cp models/gesture_model.tflite ../mobile/assets/
   cp models/gesture_classes.json ../mobile/assets/
   ```

4. **Update Flutter App**
   - Ensure `pubspec.yaml` includes the assets
   - Rebuild the app

## Testing

### Backend API Testing

```bash
cd backend
npm run start:dev

# Test endpoints
curl http://localhost:3000/auth/register -d '{"email":"test@test.com","password":"test123"}'
curl http://localhost:3000/auth/login -d '{"email":"test@test.com","password":"test123"}'
```

### Mobile App Testing

1. **Run on Emulator/Simulator**
   ```bash
   cd mobile
   flutter run
   ```

2. **Run on Physical Device**
   ```bash
   flutter run -d <device-id>
   ```

## Troubleshooting

### Backend Issues

- **Database Connection**: Verify environment variables are set correctly
- **CORS Errors**: Check CORS configuration in `main.ts`
- **Port Issues**: Ensure PORT environment variable matches service configuration

### Mobile App Issues

- **Model Not Loading**: Verify `gesture_model.tflite` is in `assets/` and listed in `pubspec.yaml`
- **Camera Permissions**: Check AndroidManifest.xml and Info.plist
- **API Connection**: Verify base URL and network permissions

## Production Checklist

- [ ] Backend deployed and accessible
- [ ] Database configured and connected
- [ ] Environment variables set
- [ ] JWT secret is secure and random
- [ ] CORS configured for mobile app domain
- [ ] TFLite model included in app assets
- [ ] API base URL updated in Flutter app
- [ ] Camera permissions configured
- [ ] App tested on both Android and iOS
- [ ] Error handling implemented
- [ ] Logging configured

