# Start Training the TSL Model - Quick Start Guide

## Prerequisites Check

Before starting, ensure you have:
- [ ] Python 3.8 or higher
- [ ] TSL dataset downloaded (or use test mode)
- [ ] ~2-4 GB free disk space
- [ ] 4-8 hours for training (depending on hardware)

## Quick Start (3 Steps)

### Step 1: Install Dependencies

```bash
cd ml
./setup_environment.sh
```

Or manually:
```bash
cd ml
python3 -m pip install -r requirements.txt
```

### Step 2: Prepare Dataset

**Option A: Use TSL Dataset (Recommended)**
1. Download from: https://data.mendeley.com/datasets/fbjjgzgv7f
2. Extract to: `dataset/tsl_dataset/`
3. Run organization script:
   ```bash
   python3 organize_tsl_dataset_smart.py
   ```
4. Manually organize any unmapped images

**Option B: Test Mode (No Dataset Needed)**
- Script will use ASL dataset or synthetic data for testing
- Good for testing the pipeline

### Step 3: Run Training

```bash
./run_training.sh
```

Or manually:
```bash
python3 train_tsl_enhanced.py
```

## What Happens During Training

1. **Landmark Extraction** (10-30 min)
   - Processes all images
   - Extracts MediaPipe landmarks
   - Normalizes to 42 features

2. **Data Augmentation** (1-2 min)
   - Applies noise, scaling, etc.
   - Increases dataset size 3-5x

3. **Model Training** (2-6 hours)
   - Trains neural network
   - Saves best model weights
   - Monitors validation loss

4. **Evaluation** (5-10 min)
   - Tests on held-out test set
   - Generates metrics and plots
   - Creates confusion matrix

5. **TFLite Conversion** (1-2 min)
   - Converts to mobile format
   - Applies quantization
   - Validates conversion

## Expected Output

After training, you'll have:

```
models/
├── tsl_model.h5                    # Keras model
├── tsl_gesture_model.tflite        # Mobile model
├── tsl_model_classes.json          # Class labels
├── tsl_model_metrics.json         # Performance metrics
├── tsl_training_history.png        # Training plots
└── tsl_confusion_matrix.npy       # Confusion matrix
```

## Training Metrics to Expect

- **Test Accuracy**: 75-85% (with real TSL dataset)
- **Top-3 Accuracy**: 90-95%
- **Training Time**: 2-6 hours (depending on hardware)
- **Model Size**: <5MB (TFLite)

## Troubleshooting

### "ModuleNotFoundError"
```bash
pip3 install -r requirements.txt
```

### "Dataset not found"
- Download TSL dataset from Mendeley
- Or use test mode: `python3 train_with_available_data.py`

### "Out of memory"
- Reduce `BATCH_SIZE` in training script
- Reduce `max_samples_per_class`
- Use smaller augmentation factor

### Training too slow
- Reduce number of epochs
- Use GPU if available (TensorFlow will auto-detect)
- Reduce dataset size for testing

## Next Steps After Training

1. **Review Results**
   ```bash
   cat models/tsl_model_metrics.json
   ```

2. **Test Model**
   ```bash
   python3 test_tsl_model.py
   ```

3. **Copy to Mobile**
   ```bash
   cp models/tsl_gesture_model.tflite ../mobile/assets/
   cp models/tsl_gesture_classes.json ../mobile/assets/
   ```

4. **Copy to Backend**
   ```bash
   cp models/tsl_model.h5 ../backend/models/
   cp models/tsl_model_classes.json ../backend/models/
   ```

## Training Scripts Available

- `train_tsl_enhanced.py` - Full training with best practices (use this)
- `train_with_available_data.py` - Test mode (works without TSL dataset)
- `organize_tsl_dataset_smart.py` - Smart dataset organization
- `convert_to_tflite.py` - Convert to mobile format
- `test_tsl_model.py` - Test trained model

## Ready to Start?

```bash
cd ml
./run_training.sh
```

This will handle everything automatically!

