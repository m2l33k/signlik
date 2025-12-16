# Quick Start: Deploy TSL Model with Backend

## Overview

This guide will help you train the TSL model and deploy it with the backend to Render or Vercel.

## Prerequisites

- Python 3.8+ with pip
- Node.js 18+
- Access to TSL dataset (Mendeley Data)

## Step 1: Train the Model

### 1.1 Download TSL Dataset

1. Visit: https://data.mendeley.com/datasets/fbjjgzgv7f
2. Download the dataset
3. Extract to `dataset/tsl_dataset/`
4. Organize images into sign folders

### 1.2 Install Python Dependencies

```bash
cd ml
pip install -r requirements.txt
```

### 1.3 Train Model

```bash
python train_tsl_model.py
```

This creates:
- `models/tsl_model.h5` - Keras model
- `models/tsl_model_classes.json` - Class labels
- Training metrics and plots

### 1.4 Convert to TFLite (Optional)

```bash
python convert_to_tflite.py
```

## Step 2: Setup Backend with Model

### 2.1 Copy Model Files

```bash
# From project root
./backend/scripts/setup_models.sh
```

Or manually:
```bash
cp ml/models/tsl_model.h5 backend/models/
cp ml/models/tsl_model_classes.json backend/models/
```

### 2.2 Install Backend Dependencies

```bash
cd backend
npm install
```

### 2.3 Test Model Loading

```bash
npm run start:dev
```

Check model status:
```bash
curl http://localhost:3000/ml/status
```

## Step 3: Deploy to Render

### 3.1 Prepare Repository

1. Commit model files (or use cloud storage)
2. Push to GitHub

### 3.2 Deploy on Render

1. Go to https://render.com
2. New → Web Service
3. Connect GitHub repository
4. Settings:
   - **Root Directory**: `backend`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm run start:prod`
5. Add Environment Variables (see `.env.example`)
6. Deploy!

### 3.3 Verify Deployment

```bash
curl https://your-app.onrender.com/ml/status
```

## Step 4: Deploy to Vercel

### 4.1 Install Vercel CLI

```bash
npm i -g vercel
```

### 4.2 Deploy

```bash
cd backend
vercel
```

Follow prompts to configure.

### 4.3 Set Environment Variables

In Vercel dashboard:
- Go to Project → Settings → Environment Variables
- Add all variables from `.env.example`

## Step 5: Test Model API

### Test Prediction

```bash
curl -X POST https://your-backend-url.com/ml/predict \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "landmarks": [0.0, 0.0, 0.1, 0.2, 0.15, 0.25, ...]
  }'
```

### Test WebSocket

```javascript
const socket = io('https://your-backend-url.com/chat', {
  auth: { token: 'YOUR_JWT_TOKEN' }
});

socket.emit('predict_gesture', {
  landmarks: [0.0, 0.0, 0.1, 0.2, ...] // 42 features
});

socket.on('gesture_prediction', (prediction) => {
  console.log('Sign:', prediction.sign);
  console.log('Confidence:', prediction.confidence);
});
```

## Integration with Chat Flow

The model is integrated into the chat flow:

1. **Mobile app** sends landmarks via WebSocket
2. **Backend** predicts gesture using ML service
3. **Backend** converts gesture to text
4. **Backend** sends message to conversation
5. **Recipients** receive message with gesture metadata

### Example Flow

```
User makes gesture → Mobile extracts landmarks → 
WebSocket: predict_gesture → Backend ML service → 
Prediction: "hello" (95% confidence) → 
Send message: "hello" → 
Chat displays message with gesture info
```

## Troubleshooting

### Model Not Found

- Check `backend/models/` directory exists
- Verify model files are committed to git
- Check file paths in `ml.service.ts`

### TensorFlow.js Errors

- Ensure `@tensorflow/tfjs-node` is installed
- Check Node.js version (18+ recommended)
- Verify model file format (H5)

### Low Performance

- Use model quantization
- Consider separate Python ML service
- Use caching for repeated predictions

## Next Steps

1. ✅ Train model
2. ✅ Deploy backend
3. ✅ Test model API
4. ✅ Integrate with mobile app
5. ✅ Monitor performance

## Support

- Check logs: Render dashboard or `vercel logs`
- Test locally: `npm run start:dev`
- Verify model: `python ml/test_tsl_model.py`

