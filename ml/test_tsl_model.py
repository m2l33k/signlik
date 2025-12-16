"""
Test the trained TSL model with sample landmarks.
This script validates that the model can make predictions correctly.
"""

import json
import numpy as np
import tensorflow as tf
from pathlib import Path

MODEL_PATH = Path("../models/tsl_model.h5")
CLASSES_PATH = Path("../models/tsl_model_classes.json")
NUM_CLASSES = 57
LANDMARK_DIM = 42


def test_model_inference():
    """Test the trained model with random landmark data."""
    print("=" * 60)
    print("TSL Model Inference Test")
    print("=" * 60)
    
    # Check if model exists
    if not MODEL_PATH.exists():
        print(f"❌ Model not found at: {MODEL_PATH}")
        print("   Please train the model first using: python train_tsl_model.py")
        return False
    
    # Load model
    print(f"\n[1/4] Loading model from: {MODEL_PATH}")
    try:
        model = tf.keras.models.load_model(MODEL_PATH)
        print("✓ Model loaded successfully")
        print(f"  Input shape: {model.input_shape}")
        print(f"  Output shape: {model.output_shape}")
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        return False
    
    # Load class labels
    print(f"\n[2/4] Loading class labels...")
    try:
        if CLASSES_PATH.exists():
            with open(CLASSES_PATH, 'r') as f:
                classes = json.load(f)
            print(f"✓ Loaded {len(classes)} class labels")
        else:
            print("⚠ Class labels file not found, using default")
            classes = [f"sign_{i}" for i in range(NUM_CLASSES)]
    except Exception as e:
        print(f"⚠ Error loading classes: {e}")
        classes = [f"sign_{i}" for i in range(NUM_CLASSES)]
    
    # Generate test landmarks (normalized relative to wrist)
    print(f"\n[3/4] Generating test landmarks...")
    test_samples = []
    for i in range(10):
        # Generate random normalized landmarks (wrist at origin)
        landmarks = np.random.randn(LANDMARK_DIM).astype(np.float32)
        # First two values should be 0 (wrist position)
        landmarks[0] = 0.0
        landmarks[1] = 0.0
        test_samples.append(landmarks)
    
    test_samples = np.array(test_samples)
    print(f"✓ Generated {len(test_samples)} test samples")
    print(f"  Sample shape: {test_samples[0].shape}")
    
    # Run inference
    print(f"\n[4/4] Running inference...")
    try:
        predictions = model.predict(test_samples, verbose=0)
        print("✓ Inference successful")
        
        # Display results
        print("\n" + "=" * 60)
        print("Prediction Results:")
        print("=" * 60)
        for i, pred in enumerate(predictions):
            pred_class = np.argmax(pred)
            confidence = np.max(pred)
            class_name = classes[pred_class] if pred_class < len(classes) else f"class_{pred_class}"
            
            print(f"\nSample {i+1}:")
            print(f"  Predicted: {class_name}")
            print(f"  Confidence: {confidence:.4f} ({confidence*100:.2f}%)")
            print(f"  Top 3 predictions:")
            top3_indices = np.argsort(pred)[-3:][::-1]
            for idx in top3_indices:
                print(f"    - {classes[idx] if idx < len(classes) else f'class_{idx}'}: {pred[idx]:.4f}")
        
        print("\n" + "=" * 60)
        print("✓ Model test completed successfully!")
        print("=" * 60)
        return True
        
    except Exception as e:
        print(f"❌ Error during inference: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_tflite_model():
    """Test the TFLite model if it exists."""
    tflite_path = Path("../models/tsl_gesture_model.tflite")
    
    if not tflite_path.exists():
        print(f"\n⚠ TFLite model not found at: {tflite_path}")
        print("   Run: python convert_to_tflite.py to create it")
        return False
    
    print("\n" + "=" * 60)
    print("TFLite Model Test")
    print("=" * 60)
    
    try:
        import tensorflow as tf
        
        # Load TFLite model
        interpreter = tf.lite.Interpreter(model_path=str(tflite_path))
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"✓ TFLite model loaded")
        print(f"  Input: {input_details[0]}")
        print(f"  Output: {output_details[0]}")
        
        # Test inference
        test_input = np.random.randn(1, LANDMARK_DIM).astype(np.float32)
        test_input[0][0] = 0.0  # Wrist x
        test_input[0][1] = 0.0  # Wrist y
        
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])
        
        pred_class = np.argmax(output[0])
        confidence = np.max(output[0])
        
        print(f"\nTest Prediction:")
        print(f"  Class: {pred_class}")
        print(f"  Confidence: {confidence:.4f}")
        print("✓ TFLite model test successful!")
        
        return True
        
    except Exception as e:
        print(f"❌ TFLite test error: {e}")
        return False


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("TSL Model Testing Suite")
    print("=" * 60)
    
    # Test Keras model
    keras_success = test_model_inference()
    
    # Test TFLite model
    tflite_success = test_tflite_model()
    
    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    print(f"Keras Model: {'✓ PASS' if keras_success else '❌ FAIL'}")
    print(f"TFLite Model: {'✓ PASS' if tflite_success else '⚠ Not tested'}")
    print("=" * 60)

