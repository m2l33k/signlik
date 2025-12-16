# Gesture AI Mobile App

Flutter mobile application for real-time ASL gesture recognition using TensorFlow Lite.

## Setup

1. **Install Flutter**
   - Follow instructions at https://flutter.dev/docs/get-started/install

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Add Model Assets**
   - Copy `models/gesture_model.tflite` to `assets/`
   - Copy `models/gesture_classes.json` to `assets/`
   - Ensure `pubspec.yaml` includes these assets

4. **Configure Backend URL**
   - Edit `lib/services/api_service.dart`
   - Update `baseUrl` to your deployed backend

## Running

### Android
```bash
flutter run
```

### iOS
```bash
flutter run
```

## Building

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Features

- Real-time hand gesture recognition
- On-device ML inference (offline support)
- Text-to-speech output
- Gesture history tracking
- User authentication
- Beautiful, accessible UI

## Architecture

- **Hand Tracking**: `lib/services/hand_tracker.dart`
- **ML Inference**: `lib/services/gesture_classifier.dart`
- **API Client**: `lib/services/api_service.dart`
- **UI Screens**: `lib/screens/`
- **Widgets**: `lib/widgets/`

## Requirements

- Flutter SDK 3.0.0+
- Android SDK 21+ (Android 5.0+)
- iOS 12.0+
- Camera permission
- Internet connection (for API features)

