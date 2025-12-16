#!/bin/bash

# TSL Model Training Execution Script
# This script runs the complete training pipeline

set -e  # Exit on error

echo "============================================================"
echo "TSL Model Training Pipeline"
echo "============================================================"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Please install Python 3.8+"
    exit 1
fi

# Check dependencies
echo ""
echo "[1/5] Checking dependencies..."
python3 -c "import tensorflow; import mediapipe; import cv2; import numpy; print('✓ All dependencies installed')" 2>/dev/null || {
    echo "⚠ Dependencies not installed. Installing..."
    pip3 install -r requirements.txt --user
}

# Check dataset
echo ""
echo "[2/5] Checking dataset..."
if [ -d "../dataset/tsl_dataset/organized" ] && [ "$(ls -A ../dataset/tsl_dataset/organized 2>/dev/null)" ]; then
    echo "✓ TSL dataset found"
    DATASET_READY=true
else
    echo "⚠ TSL dataset not found"
    echo "  Options:"
    echo "  1. Download from: https://data.mendeley.com/datasets/fbjjgzgv7f"
    echo "  2. Organize images into: dataset/tsl_dataset/organized/"
    echo "  3. Or use test mode with ASL dataset"
    DATASET_READY=false
fi

# Organize dataset (if needed)
if [ "$DATASET_READY" = false ]; then
    echo ""
    echo "[3/5] Attempting smart dataset organization..."
    python3 organize_tsl_dataset_smart.py
fi

# Train model
echo ""
echo "[4/5] Training model..."
if [ "$DATASET_READY" = true ]; then
    echo "  Using TSL dataset"
    python3 train_tsl_enhanced.py
else
    echo "  Using available data (test mode)"
    python3 train_with_available_data.py
fi

# Convert to TFLite
echo ""
echo "[5/5] Converting to TFLite..."
if [ -f "../models/tsl_model.h5" ]; then
    python3 convert_to_tflite.py
    echo "✓ TFLite conversion complete"
else
    echo "⚠ Model not found. Training may have failed."
    exit 1
fi

# Copy to deployment locations
echo ""
echo "Copying models to deployment locations..."
if [ -f "../models/tsl_gesture_model.tflite" ]; then
    mkdir -p ../mobile/assets
    mkdir -p ../backend/models
    cp ../models/tsl_gesture_model.tflite ../mobile/assets/ 2>/dev/null || true
    cp ../models/tsl_gesture_classes.json ../mobile/assets/ 2>/dev/null || true
    cp ../models/tsl_model.h5 ../backend/models/ 2>/dev/null || true
    cp ../models/tsl_model_classes.json ../backend/models/ 2>/dev/null || true
    echo "✓ Models copied to mobile and backend"
fi

echo ""
echo "============================================================"
echo "Training Pipeline Complete!"
echo "============================================================"
echo "Model files:"
ls -lh ../models/tsl_* 2>/dev/null || echo "  (Check models/ directory)"
echo ""
echo "Next steps:"
echo "  1. Review training metrics in models/tsl_model_metrics.json"
echo "  2. Check training plots in models/tsl_training_history.png"
echo "  3. Test model: python3 test_tsl_model.py"
echo "  4. Deploy to mobile and backend"
echo "============================================================"

