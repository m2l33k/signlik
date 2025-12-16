# Deploying TSL Model with Backend

## Overview

This guide explains how to deploy the trained TSL model along with the NestJS backend to Render or Vercel.

## Model Files Required

Before deployment, ensure you have:

1. **Trained Model**: `models/tsl_model.h5` (Keras format)
2. **Class Labels**: `models/tsl_model_classes.json`
3. **TFLite Model** (optional): `models/tsl_gesture_model.tflite`

## Step 1: Train the Model

```bash
cd ml
python train_tsl_model.py
python convert_to_tflite.py
```

## Step 2: Copy Model to Backend

```bash
# Copy model files to backend
cp models/tsl_model.h5 ../backend/models/
cp models/tsl_model_classes.json ../backend/models/
cp models/tsl_gesture_model.tflite ../backend/models/  # Optional
```

## Step 3: Deploy to Render

### Option A: Render Web Service

1. **Create New Web Service**
   - Connect your GitHub repository
   - Select `backend` as root directory

2. **Build Settings**
   - Build Command: `npm install && npm run build`
   - Start Command: `npm run start:prod`

3. **Environment Variables**
   ```env
   NODE_ENV=production
   PORT=10000
   DB_HOST=your-db-host
   DB_PORT=5432
   DB_USERNAME=your-username
   DB_PASSWORD=your-password
   DB_NAME=gesture_ai
   DB_SSL=true
   JWT_SECRET=your-secret-key
   ```

4. **Model Files**
   - Render will include files from your repository
   - Ensure `backend/models/` directory is committed to git
   - Model files will be available at runtime

### Option B: Render with Model Storage

For larger models, consider:
- Storing models in S3/cloud storage
- Loading models from URL at startup
- Using Render's persistent disk (if available)

## Step 4: Deploy to Vercel

### Setup

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Configure for NestJS**
   - Vercel auto-detects NestJS
   - Ensure `vercel.json` is configured

3. **Deploy**
   ```bash
   cd backend
   vercel
   ```

4. **Model Files**
   - Vercel includes all files in deployment
   - Models are available at runtime
   - Consider using Vercel Blob Storage for large models

## Step 5: Verify Model Loading

After deployment, check model status:

```bash
curl https://your-backend-url.com/ml/status
```

Expected response:
```json
{
  "success": true,
  "loaded": true,
  "classes": 57,
  "modelPath": "/path/to/model"
}
```

## Model API Endpoints

### Predict Gesture
```bash
POST /ml/predict
Authorization: Bearer <token>
Content-Type: application/json

{
  "landmarks": [0.0, 0.0, 0.1, 0.2, ...] // 42 features
}
```

Response:
```json
{
  "success": true,
  "class": 0,
  "confidence": 0.95,
  "sign": "hello",
  "probabilities": [0.95, 0.02, ...]
}
```

### Get Model Status
```bash
GET /ml/status
```

### Get Class Labels
```bash
GET /ml/classes
```

## WebSocket Integration

The model is also accessible via WebSocket:

```javascript
socket.emit('predict_gesture', {
  landmarks: [0.0, 0.0, 0.1, 0.2, ...] // 42 features
});

socket.on('gesture_prediction', (prediction) => {
  console.log('Predicted:', prediction.sign);
  console.log('Confidence:', prediction.confidence);
});
```

## Troubleshooting

### Model Not Loading

1. **Check File Paths**
   - Verify model files are in `backend/models/`
   - Check file permissions
   - Ensure files are committed to git

2. **Check Logs**
   ```bash
   # Render
   View logs in Render dashboard
   
   # Vercel
   vercel logs
   ```

3. **Verify TensorFlow.js**
   - Ensure `@tensorflow/tfjs-node` is installed
   - Check Node.js version compatibility

### Performance Issues

1. **Model Size**
   - Use quantization for smaller models
   - Consider model pruning
   - Use TFLite for mobile, Keras for backend

2. **Memory**
   - Render: Upgrade service tier if needed
   - Vercel: Check function memory limits

3. **Cold Starts**
   - Model loads on first request
   - Consider keeping service warm
   - Use model caching

## Alternative: Python ML Service

For better performance, consider a separate Python service:

1. **Create Python Service** (Flask/FastAPI)
2. **Deploy separately** (Render, Railway, etc.)
3. **Call from NestJS** via HTTP

This approach:
- Better TensorFlow support
- Can use TFLite interpreter
- Easier model updates
- Better performance

## Next Steps

1. Train model with TSL dataset
2. Copy model files to backend
3. Deploy backend to Render/Vercel
4. Test model endpoints
5. Integrate with mobile app

