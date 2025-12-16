# Tunisian Sign Language (TSL) Chat Application Setup Guide

## Overview

This is a WhatsApp-like chat application that enables communication between deaf and hearing users using Tunisian Sign Language (TSL). The app supports:

1. **Gesture-to-Text**: Deaf users make TSL gestures → converted to text and sent
2. **Text-to-Gesture**: Text messages → displayed with TSL gesture images underneath for deaf users who can't read

## Dataset

### Download TSL Dataset

1. Visit: https://data.mendeley.com/datasets/fbjjgzgv7f
2. Download the "First ever Tunisian Sign Language Dataset"
3. Extract to: `dataset/tsl_dataset/`
4. The dataset contains:
   - 4,423 images
   - 57 standard Tunisian signs
   - 7 individuals
   - Diverse environments

### Organize Dataset

```bash
cd ml
python download_tsl_dataset.py
```

This will create the organized directory structure. You may need to manually organize images into sign folders based on the dataset structure.

## Model Training

### Step 1: Extract Landmarks and Train Model

```bash
cd ml
pip install -r requirements.txt
python train_tsl_model.py
```

This will:
- Extract MediaPipe landmarks from TSL images
- Apply data augmentation
- Train a model for 57 TSL signs
- Save model to `models/tsl_model.h5`

### Step 2: Convert to TFLite

```bash
python convert_to_tflite.py
```

This creates `models/tsl_gesture_model.tflite` for mobile deployment.

### Step 3: Copy to Mobile App

```bash
cp models/tsl_gesture_model.tflite ../mobile/assets/
cp models/tsl_gesture_classes.json ../mobile/assets/
```

## Gesture Image Library

You need to create gesture images for text-to-gesture visualization:

1. Create directory: `mobile/assets/gestures/`
2. For each of the 57 TSL signs, add an image file:
   - Format: `{sign_name}.png`
   - Example: `hello.png`, `yes.png`, `no.png`, etc.
3. Images should show the TSL gesture clearly

You can:
- Extract representative images from the TSL dataset
- Use a gesture visualization tool
- Create custom gesture images

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Create `.env` file:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=gesture_ai
DB_SSL=false
JWT_SECRET=your-secret-key-change-in-production
PORT=3000
NODE_ENV=development
```

### 3. Run Database Migrations

TypeORM will auto-sync in development. For production, use migrations.

### 4. Start Backend

```bash
npm run start:dev
```

The backend will run on `http://localhost:3000`

## Mobile App Setup

### 1. Install Flutter Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Configure Backend URL

Edit `mobile/lib/services/chat_service.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:3000';
```

### 3. Ensure Assets Are Included

Check `mobile/pubspec.yaml` includes:
- `assets/tsl_gesture_model.tflite`
- `assets/tsl_gesture_classes.json`
- `assets/tsl_word_mappings.json`
- `assets/tsl_letter_mappings.json`
- `assets/gestures/`

### 4. Run Mobile App

```bash
flutter run
```

## Features

### Chat Interface

- **Conversations Screen**: List of all conversations
- **Chat Screen**: Individual conversation view
- **Gesture Input**: Camera-based gesture recognition
- **Text Input**: Standard keyboard input
- **Gesture Display**: Shows TSL gestures under text messages

### How It Works

1. **Deaf User Sending Message**:
   - Tap camera icon to switch to gesture input
   - Make TSL gesture in front of camera
   - App recognizes gesture and converts to text
   - Tap "Send" to send message

2. **Deaf User Receiving Message**:
   - Text message appears in chat
   - TSL gesture images appear underneath the text
   - User can see gestures to understand the message

3. **Hearing User**:
   - Types normally using keyboard
   - Messages sent as text
   - If recipient is deaf, gestures appear under messages

## Testing

### Test Gesture Recognition

1. Open chat screen
2. Switch to gesture input mode
3. Make TSL gestures
4. Verify recognition accuracy

### Test Text-to-Gesture

1. Send a text message
2. Verify gesture images appear underneath
3. Check gesture mapping is correct

### Test Real-time Messaging

1. Open app on two devices/emulators
2. Create conversation between users
3. Send messages and verify real-time delivery

## Deployment

### Backend (Render)

1. Connect GitHub repository
2. Select `backend` directory
3. Set environment variables
4. Deploy

### Backend (Vercel)

```bash
cd backend
vercel
```

### Mobile App

1. Update API base URL in `chat_service.dart`
2. Build for Android/iOS
3. Deploy to app stores

## Troubleshooting

### Model Not Loading

- Verify `tsl_gesture_model.tflite` is in `assets/`
- Check `pubspec.yaml` includes the asset
- Rebuild app: `flutter clean && flutter pub get`

### Gestures Not Displaying

- Verify gesture images exist in `assets/gestures/`
- Check gesture mapping in `tsl_word_mappings.json`
- Verify `GestureMapper` is loading correctly

### WebSocket Connection Issues

- Check backend is running
- Verify JWT token is valid
- Check CORS configuration
- Verify WebSocket URL is correct

## Next Steps

- Video calling functionality
- Group chats
- Media sharing
- Offline message support
- Gesture animation sequences

