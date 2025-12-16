# Tunisian Sign Language (TSL) Model Training Guide

## Overview

This guide explains how to train the AI model for recognizing 57 Tunisian Sign Language (TSL) gestures using MediaPipe hand landmarks.

## Dataset

### Download TSL Dataset

1. Visit: https://data.mendeley.com/datasets/fbjjgzgv7f
2. Download the "First ever Tunisian Sign Language Dataset"
3. Extract to: `dataset/tsl_dataset/`
4. Dataset contains:
   - 4,423 images
   - 57 standard Tunisian signs
   - 7 individuals
   - Diverse environments

### Organize Dataset

The dataset should be organized in the following structure:

```
dataset/tsl_dataset/organized/
├── hello/
│   ├── image1.jpg
│   ├── image2.jpg
│   └── ...
├── yes/
│   ├── image1.jpg
│   └── ...
├── no/
└── ... (57 sign folders)
```

You can use the download script to create the folder structure:

```bash
python download_tsl_dataset.py
```

Then manually organize images into the appropriate sign folders based on the dataset structure.

## Training the Model

### Step 1: Install Dependencies

```bash
pip install -r requirements.txt
```

Required packages:
- tensorflow==2.16.1
- mediapipe==0.10.11
- numpy==1.26.4
- opencv-python==4.10.0.84
- scikit-learn==1.5.2
- matplotlib==3.9.2

### Step 2: Extract Landmarks and Train

```bash
python train_tsl_model.py
```

This script will:
1. Extract MediaPipe hand landmarks from all TSL images
2. Normalize landmarks relative to wrist (42 features: 21 points × 2)
3. Apply data augmentation (noise, scaling)
4. Split data into train/validation/test sets
5. Train a neural network model
6. Evaluate and save metrics
7. Save model to `models/tsl_model.h5`

**Expected Output:**
- Model file: `models/tsl_model.h5`
- Class labels: `models/tsl_model_classes.json`
- Training plots: `models/tsl_model_accuracy.png`, `models/tsl_model_loss.png`
- Metrics: `models/tsl_model_metrics.json`

### Step 3: Convert to TFLite

```bash
python convert_to_tflite.py
```

This creates:
- `models/tsl_gesture_model.tflite` - Mobile-optimized model
- `models/tsl_gesture_classes.json` - Class labels for mobile

### Step 4: Test the Model

```bash
python test_tsl_model.py
```

This validates:
- Model can be loaded
- Inference works correctly
- TFLite conversion is valid

## Model Architecture

- **Input**: 42 features (21 hand landmarks × 2 coordinates, normalized relative to wrist)
- **Architecture**: Dense neural network
  - Dense(256) → BatchNorm → Dropout(0.4)
  - Dense(128) → BatchNorm → Dropout(0.3)
  - Dense(64) → BatchNorm → Dropout(0.2)
  - Dense(57) → Softmax
- **Output**: 57 TSL sign classes with probabilities

## Model Performance

Target metrics:
- **Accuracy**: >85% on test set
- **Top-3 Accuracy**: >95%
- **Inference Speed**: <50ms per prediction (mobile)

## Integration with Mobile App

After training:

1. Copy TFLite model to mobile assets:
   ```bash
   cp models/tsl_gesture_model.tflite ../mobile/assets/
   cp models/tsl_gesture_classes.json ../mobile/assets/
   ```

2. The mobile app's `GestureClassifierService` will automatically:
   - Load the TFLite model
   - Process landmarks from camera
   - Return predictions with confidence scores

## Troubleshooting

### No landmarks extracted
- Check that images contain visible hands
- Verify MediaPipe is detecting hands (try with sample images)
- Ensure images are in correct format (JPG, PNG)

### Low accuracy
- Increase data augmentation
- Collect more training data
- Adjust model architecture
- Check for class imbalance

### Model too large
- Use quantization in TFLite conversion
- Reduce model size (fewer neurons)
- Use model pruning

## Next Steps

1. Train model with your organized dataset
2. Evaluate accuracy and adjust if needed
3. Convert to TFLite
4. Test on mobile device
5. Deploy to production

