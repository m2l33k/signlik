# Gesture AI: Empowering Communication for All (IEEE Challenge Submission)

A Next.js + TensorFlow.js + MediaPipe Hands web application that translates hand gestures into text and speech in real-time, designed to **empower deaf and speech-impaired communities** by breaking down communication barriers and promoting social inclusion.

## 🌍 Social Impact Focus
This project addresses **Inequality and Social Exclusion** in the IEEE TSYP13 Technical Challenge's Social Crisis category by:
- Providing accessible communication tools for disabled individuals
- Enabling participation in education, healthcare, and daily social interactions
- Promoting equity and community resilience through open-source, low-cost technology
- Aligning with UN SDGs: SDG 10 (Reduced Inequalities), SDG 4 (Quality Education), SDG 3 (Good Health and Well-being)

## ⚡ Technical Overview

### Web Application (Next.js)
- **Frontend**: Next.js 15 (React 19, TypeScript) for responsive web interface
- **Hand Tracking**: MediaPipe Hands (21 landmark points, privacy-first, browser-based)
- **ML Inference**: TensorFlow.js for real-time gesture classification
- **Speech Output**: Web Speech API for text-to-speech conversion

### Mobile Application (Flutter)
- **Platform**: Flutter (Android + iOS)
- **Hand Tracking**: MediaPipe Hands integration
- **ML Inference**: TensorFlow Lite for on-device gesture classification
- **Backend**: NestJS REST API for user management and gesture history
- **Speech**: Flutter TTS for text-to-speech

### Backend (NestJS)
- **Framework**: NestJS with TypeScript
- **Database**: PostgreSQL (TypeORM)
- **Authentication**: JWT-based auth
- **API**: RESTful endpoints for users, gestures, and analytics

## 🚀 Quick Start

### Web Application
```bash
npm install
npm run dev
```
Open `http://localhost:3000` and allow camera access.

### Mobile Application
```bash
cd mobile
flutter pub get
flutter run
```

### Backend API
```bash
cd backend
npm install
# Set up .env file (see backend/.env.example)
npm run start:dev
```

## 📁 Project Structure

```
.
├── src/                    # Next.js web app
├── mobile/                  # Flutter mobile app
│   ├── lib/
│   │   ├── services/       # Hand tracking, ML, API
│   │   ├── screens/        # UI screens
│   │   └── widgets/         # Reusable components
│   └── assets/              # TFLite model and assets
├── backend/                 # NestJS backend
│   ├── src/
│   │   ├── auth/           # Authentication
│   │   ├── users/           # User management
│   │   ├── gestures/       # Gesture history
│   │   └── ml/              # ML inference service
│   └── dist/                # Compiled output
└── ml/                      # ML training scripts
    ├── train_landmark_model.py
    └── convert_to_tflite.py
```

## 🤝 Community Partnership
In collaboration with local disability organizations to ensure cultural relevance and real-world impact.

## 📊 Challenge Alignment
- **Humanitarian Impact**: Empowers vulnerable communities with inclusive technology
- **Sustainability**: Open-source, low-resource deployment
- **Ethical Values**: Transparency, equity, and community ownership

## 📖 Documentation

- [Project Overview](./PROJECT_OVERVIEW.md) - Detailed architecture and implementation
- [Deployment Guide](./DEPLOYMENT.md) - How to deploy to Render, Vercel, etc.

## 🔧 Development

### Training the Model

1. **Prepare Dataset**
   - Place ASL alphabet images in `dataset/asl_alphabet_kaggle/`

2. **Train Landmark Model**
   ```bash
   cd ml
   pip install -r requirements.txt
   python train_landmark_model.py
   ```

3. **Convert to TFLite**
   ```bash
   python convert_to_tflite.py
   ```

4. **Copy to Mobile App**
   ```bash
   cp models/gesture_model.tflite ../mobile/assets/
   cp models/gesture_classes.json ../mobile/assets/
   ```

### Backend Development

```bash
cd backend
npm install
npm run start:dev
```

### Mobile Development

```bash
cd mobile
flutter pub get
flutter run
```

## 📱 Mobile App Features

- Real-time hand gesture recognition
- On-device ML inference (works offline)
- Text-to-speech output
- Gesture history tracking
- User authentication
- Analytics and statistics

## 🌐 API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/profile` - Get user profile

### Gestures
- `GET /gestures/history` - Get gesture history
- `POST /gestures/history` - Save gesture
- `GET /gestures/stats` - Get statistics

### Users
- `GET /users` - List users (admin)
- `GET /users/:id` - Get user details
- `PATCH /users/:id` - Update user
- `DELETE /users/:id` - Delete user

## 🚢 Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

### Quick Deploy

**Backend (Render)**
1. Connect GitHub repository
2. Select `backend` directory
3. Set environment variables
4. Deploy

**Mobile App**
1. Update API base URL in `mobile/lib/services/api_service.dart`
2. Build for Android/iOS
3. Distribute via app stores

## 📄 License

MIT

---
*IEEE TSYP13 Technical Challenge Submission - Social Crisis Track*
