# Manual Tasks Checklist

This document lists ALL manual tasks that need to be completed before the AI model can be fully integrated and deployed.

## 📋 Overview

While most of the code is automated, there are several manual steps required to prepare the dataset, train the model, and set up assets. This checklist ensures nothing is missed.

---

## Phase 1: Dataset Preparation (Manual)

### Task 1.1: Download TSL Dataset
- [ ] **Action**: Visit https://data.mendeley.com/datasets/fbjjgzgv7f
- [ ] **Action**: Create Mendeley account (if needed)
- [ ] **Action**: Download dataset ZIP file(s)
- [ ] **Action**: Extract ZIP file to `dataset/tsl_dataset/`
- [ ] **Time Estimate**: 30-60 minutes
- [ ] **Notes**: Large file download, ensure stable internet

### Task 1.2: Organize Dataset Images (MANUAL)
- [ ] **Action**: Review extracted dataset structure
- [ ] **Action**: Identify how images are organized in source
- [ ] **Action**: Create 57 sign folders in `dataset/tsl_dataset/organized/`
  - [ ] hello/
  - [ ] goodbye/
  - [ ] thank_you/
  - [ ] please/
  - [ ] sorry/
  - [ ] yes/
  - [ ] no/
  - [ ] maybe/
  - [ ] ok/
  - [ ] help/
  - [ ] mother/
  - [ ] father/
  - [ ] brother/
  - [ ] sister/
  - [ ] family/
  - [ ] water/
  - [ ] food/
  - [ ] eat/
  - [ ] drink/
  - [ ] sleep/
  - [ ] house/
  - [ ] school/
  - [ ] work/
  - [ ] home/
  - [ ] friend/
  - [ ] today/
  - [ ] tomorrow/
  - [ ] yesterday/
  - [ ] morning/
  - [ ] evening/
  - [ ] what/
  - [ ] where/
  - [ ] when/
  - [ ] why/
  - [ ] how/
  - [ ] who/
  - [ ] go/
  - [ ] come/
  - [ ] see/
  - [ ] hear/
  - [ ] speak/
  - [ ] read/
  - [ ] write/
  - [ ] learn/
  - [ ] teach/
  - [ ] understand/
  - [ ] zero/
  - [ ] one/
  - [ ] two/
  - [ ] three/
  - [ ] four/
  - [ ] five/
  - [ ] six/
  - [ ] seven/
  - [ ] eight/
  - [ ] nine/
  - [ ] good/
  - [ ] bad/
  - [ ] happy/
  - [ ] sad/
  - [ ] love/
  - [ ] like/
  - [ ] want/
  - [ ] need/
- [ ] **Action**: Copy images from source to appropriate sign folders
- [ ] **Action**: Verify each folder has images (target: 50-100+ per sign)
- [ ] **Action**: Remove corrupted or invalid images
- [ ] **Time Estimate**: 2-4 hours
- [ ] **Notes**: This is the most time-consuming manual task. Consider using a script to help organize if dataset has consistent naming.

### Task 1.3: Verify Dataset Organization
- [ ] **Action**: Count total images: `find dataset/tsl_dataset/organized -name "*.jpg" -o -name "*.png" | wc -l`
- [ ] **Action**: Should be close to 4,423 images
- [ ] **Action**: Count sign folders: `ls -d dataset/tsl_dataset/organized/*/ | wc -l`
- [ ] **Action**: Should be exactly 57 folders
- [ ] **Action**: Check for empty folders
- [ ] **Action**: Verify image formats (JPG/PNG)
- [ ] **Time Estimate**: 15-30 minutes

---

## Phase 2: Model Training (Automated, but requires monitoring)

### Task 2.1: Install Python Dependencies
- [ ] **Action**: `cd ml && pip install -r requirements.txt`
- [ ] **Action**: Verify all packages installed correctly
- [ ] **Time Estimate**: 5-10 minutes
- [ ] **Notes**: May need to install system dependencies (MediaPipe requirements)

### Task 2.2: Run Training Script
- [ ] **Action**: `cd ml && python train_tsl_model.py`
- [ ] **Action**: Monitor training progress
- [ ] **Action**: Check for errors during training
- [ ] **Action**: Review training logs
- [ ] **Time Estimate**: 4-8 hours (depending on hardware)
- [ ] **Notes**: Training runs automatically, but needs monitoring

### Task 2.3: Review Training Results
- [ ] **Action**: Check `models/tsl_model_accuracy.png` (accuracy plot)
- [ ] **Action**: Check `models/tsl_model_loss.png` (loss plot)
- [ ] **Action**: Review `models/tsl_model_metrics.json` (accuracy metrics)
- [ ] **Action**: Verify test accuracy is 75-85%+
- [ ] **Action**: Check per-class accuracy for problematic signs
- [ ] **Time Estimate**: 15-30 minutes

### Task 2.4: Convert to TFLite
- [ ] **Action**: `cd ml && python convert_to_tflite.py`
- [ ] **Action**: Verify `models/tsl_gesture_model.tflite` created
- [ ] **Action**: Check model size (should be <5MB)
- [ ] **Action**: Test TFLite model: `python test_tsl_model.py`
- [ ] **Time Estimate**: 5-10 minutes

---

## Phase 3: Gesture Image Library (Manual)

### Task 3.1: Create Gesture Images Directory
- [ ] **Action**: Create `mobile/assets/gestures/` directory
- [ ] **Time Estimate**: 1 minute

### Task 3.2: Create 57 Gesture Images (MANUAL)
- [ ] **Action**: For each of the 57 TSL signs, create/obtain a gesture image
- [ ] **Action**: Image format: PNG (recommended) or JPG
- [ ] **Action**: Image size: 200x200 to 400x400 pixels (recommended)
- [ ] **Action**: Naming: `{sign_name}.png` (e.g., `hello.png`, `yes.png`)
- [ ] **Signs to create images for**:
  - [ ] hello.png
  - [ ] goodbye.png
  - [ ] thank_you.png
  - [ ] please.png
  - [ ] sorry.png
  - [ ] yes.png
  - [ ] no.png
  - [ ] maybe.png
  - [ ] ok.png
  - [ ] help.png
  - [ ] mother.png
  - [ ] father.png
  - [ ] brother.png
  - [ ] sister.png
  - [ ] family.png
  - [ ] water.png
  - [ ] food.png
  - [ ] eat.png
  - [ ] drink.png
  - [ ] sleep.png
  - [ ] house.png
  - [ ] school.png
  - [ ] work.png
  - [ ] home.png
  - [ ] friend.png
  - [ ] today.png
  - [ ] tomorrow.png
  - [ ] yesterday.png
  - [ ] morning.png
  - [ ] evening.png
  - [ ] what.png
  - [ ] where.png
  - [ ] when.png
  - [ ] why.png
  - [ ] how.png
  - [ ] who.png
  - [ ] go.png
  - [ ] come.png
  - [ ] see.png
  - [ ] hear.png
  - [ ] speak.png
  - [ ] read.png
  - [ ] write.png
  - [ ] learn.png
  - [ ] teach.png
  - [ ] understand.png
  - [ ] zero.png
  - [ ] one.png
  - [ ] two.png
  - [ ] three.png
  - [ ] four.png
  - [ ] five.png
  - [ ] six.png
  - [ ] seven.png
  - [ ] eight.png
  - [ ] nine.png
  - [ ] good.png
  - [ ] bad.png
  - [ ] happy.png
  - [ ] sad.png
  - [ ] love.png
  - [ ] like.png
  - [ ] want.png
  - [ ] need.png

**Options for obtaining images:**
1. Extract representative images from TSL dataset (one per sign)
2. Use gesture visualization tools
3. Create custom illustrations
4. Use stock gesture images (if available)
5. Collaborate with TSL signers to create images

- [ ] **Time Estimate**: 2-4 hours (depending on method)
- [ ] **Notes**: This is critical for text-to-gesture feature

### Task 3.3: Verify Gesture Images
- [ ] **Action**: Count images: `ls mobile/assets/gestures/*.png | wc -l`
- [ ] **Action**: Should be 57 images
- [ ] **Action**: Verify all images load correctly
- [ ] **Action**: Check image quality (clear, visible gestures)
- [ ] **Time Estimate**: 10-15 minutes

---

## Phase 4: Copy Model to Mobile (Automated)

### Task 4.1: Copy Model Files
- [ ] **Action**: Run setup script: `./backend/scripts/setup_models.sh`
- [ ] **OR Manual**:
  - [ ] `cp ml/models/tsl_gesture_model.tflite mobile/assets/`
  - [ ] `cp ml/models/tsl_gesture_classes.json mobile/assets/`
- [ ] **Action**: Verify files copied correctly
- [ ] **Time Estimate**: 2-5 minutes

### Task 4.2: Verify Mobile Assets
- [ ] **Action**: Check `mobile/assets/tsl_gesture_model.tflite` exists
- [ ] **Action**: Check `mobile/assets/tsl_gesture_classes.json` exists
- [ ] **Action**: Check `mobile/assets/gestures/` has 57 images
- [ ] **Action**: Verify `mobile/pubspec.yaml` includes all assets
- [ ] **Time Estimate**: 5 minutes

---

## Phase 5: Backend Setup (Semi-Automated)

### Task 5.1: Copy Model to Backend
- [ ] **Action**: `cp ml/models/tsl_model.h5 backend/models/`
- [ ] **Action**: `cp ml/models/tsl_model_classes.json backend/models/`
- [ ] **Action**: Verify files in `backend/models/` directory
- [ ] **Time Estimate**: 2-5 minutes

### Task 5.2: Configure Environment Variables
- [ ] **Action**: Create `backend/.env` file
- [ ] **Action**: Copy from `backend/.env.example`
- [ ] **Action**: Fill in database credentials
- [ ] **Action**: Set JWT_SECRET
- [ ] **Action**: Configure other variables
- [ ] **Time Estimate**: 10-15 minutes

### Task 5.3: Install Backend Dependencies
- [ ] **Action**: `cd backend && npm install`
- [ ] **Action**: Verify all packages installed
- [ ] **Time Estimate**: 5-10 minutes

---

## Phase 6: Testing (Manual Verification)

### Task 6.1: Test Model Loading
- [ ] **Action**: `cd backend && npm run start:dev`
- [ ] **Action**: Check logs for "Model loaded successfully"
- [ ] **Action**: Test endpoint: `curl http://localhost:3000/ml/status`
- [ ] **Action**: Verify model status shows `loaded: true`
- [ ] **Time Estimate**: 10-15 minutes

### Task 6.2: Test Model Prediction
- [ ] **Action**: Test with sample landmarks via API
- [ ] **Action**: Verify predictions are reasonable
- [ ] **Action**: Check confidence scores
- [ ] **Time Estimate**: 10-15 minutes

### Task 6.3: Test Mobile App
- [ ] **Action**: `cd mobile && flutter pub get`
- [ ] **Action**: `flutter run`
- [ ] **Action**: Test gesture recognition
- [ ] **Action**: Test text-to-gesture display
- [ ] **Action**: Verify both features work
- [ ] **Time Estimate**: 30-60 minutes

---

## Phase 7: Deployment Preparation (Manual Configuration)

### Task 7.1: Prepare for Render Deployment
- [ ] **Action**: Push code to GitHub repository
- [ ] **Action**: Verify `backend/render.yaml` is correct
- [ ] **Action**: Ensure model files are in repository (or use cloud storage)
- [ ] **Action**: Set up Render account
- [ ] **Action**: Configure environment variables in Render dashboard
- [ ] **Time Estimate**: 30-60 minutes

### Task 7.2: Prepare for Vercel Deployment
- [ ] **Action**: Install Vercel CLI: `npm i -g vercel`
- [ ] **Action**: Verify `backend/vercel.json` is correct
- [ ] **Action**: Set up Vercel account
- [ ] **Action**: Configure environment variables
- [ ] **Time Estimate**: 20-30 minutes

---

## Summary of Manual Tasks

### Critical Manual Tasks (Must Do)

1. **Download TSL Dataset** (30-60 min)
2. **Organize Dataset Images** (2-4 hours) ⚠️ **MOST TIME-CONSUMING**
3. **Create 57 Gesture Images** (2-4 hours) ⚠️ **IMPORTANT**
4. **Configure Environment Variables** (10-15 min)
5. **Test Everything** (1-2 hours)

### Total Estimated Time: **6-12 hours** of manual work

### Tasks That Can Be Automated Later

- Dataset organization (could create smarter script)
- Gesture image extraction (could auto-extract from dataset)
- Model file copying (already has script)

---

## Quick Reference: File Locations

### Dataset
- **Source**: `dataset/tsl_dataset/` (downloaded)
- **Organized**: `dataset/tsl_dataset/organized/` (manual organization)

### Models
- **Trained**: `ml/models/tsl_model.h5`
- **TFLite**: `ml/models/tsl_gesture_model.tflite`
- **Classes**: `ml/models/tsl_model_classes.json`

### Mobile Assets
- **Model**: `mobile/assets/tsl_gesture_model.tflite`
- **Classes**: `mobile/assets/tsl_gesture_classes.json`
- **Images**: `mobile/assets/gestures/*.png` (57 images)

### Backend Models
- **Model**: `backend/models/tsl_model.h5`
- **Classes**: `backend/models/tsl_model_classes.json`

---

## Notes for Future Integration

When you provide the frontend/backend:

1. **Model Service**: Already created in `backend/src/ml/ml.service.ts`
   - Just needs model files in `backend/models/`
   - Will auto-load on startup

2. **API Endpoints**: Already created
   - `POST /ml/predict` - Predict gesture from landmarks
   - `GET /ml/status` - Check model status
   - `GET /ml/classes` - Get sign labels

3. **WebSocket**: Already integrated
   - `predict_gesture` event for real-time prediction
   - Returns prediction with confidence

4. **Mobile Integration**: Ready
   - `GestureClassifierService` - Loads TFLite model
   - `GestureMapper` - Text to gesture mapping
   - UI widgets ready

**Integration Points:**
- Backend ML service is standalone (can be called from any frontend)
- Mobile app has all services ready
- Just need to connect your frontend/backend to existing services

---

## Checklist Summary

**Before Training:**
- [ ] Download dataset
- [ ] Organize images (MANUAL - 2-4 hours)
- [ ] Verify organization

**After Training:**
- [ ] Review training results
- [ ] Convert to TFLite
- [ ] Test model

**Before Mobile:**
- [ ] Create gesture images (MANUAL - 2-4 hours)
- [ ] Copy model to mobile assets
- [ ] Verify assets

**Before Backend:**
- [ ] Copy model to backend
- [ ] Configure environment
- [ ] Test model loading

**Before Deployment:**
- [ ] Test everything
- [ ] Prepare deployment configs
- [ ] Deploy

---

**Most Critical Manual Tasks:**
1. ⚠️ **Organize dataset images** (2-4 hours)
2. ⚠️ **Create gesture images** (2-4 hours)

These two tasks are the most time-consuming and cannot be fully automated.

