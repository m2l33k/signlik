#!/bin/bash

# Script to set up model files for deployment
# Run this after training the model

echo "Setting up TSL model files for backend..."

# Create models directory if it doesn't exist
mkdir -p models

# Copy model files from ml directory
if [ -f "../ml/models/tsl_model.h5" ]; then
    echo "Copying tsl_model.h5..."
    cp ../ml/models/tsl_model.h5 models/
else
    echo "Warning: tsl_model.h5 not found. Please train the model first."
fi

if [ -f "../ml/models/tsl_model_classes.json" ]; then
    echo "Copying tsl_model_classes.json..."
    cp ../ml/models/tsl_model_classes.json models/
else
    echo "Warning: tsl_model_classes.json not found."
fi

if [ -f "../ml/models/tsl_gesture_model.tflite" ]; then
    echo "Copying tsl_gesture_model.tflite..."
    cp ../ml/models/tsl_gesture_model.tflite models/
else
    echo "Info: tsl_gesture_model.tflite not found (optional)."
fi

echo "Model setup complete!"
echo "Files in models/:"
ls -lh models/

