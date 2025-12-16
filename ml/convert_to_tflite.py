"""
Convert the trained Keras landmark model to TensorFlow Lite format for mobile deployment.
"""

import json
from pathlib import Path

import numpy as np
import tensorflow as tf

MODEL_PATH = Path("../models/tsl_model.h5")
OUTPUT_DIR = Path("../models")
TFLITE_MODEL_PATH = OUTPUT_DIR / "tsl_gesture_model.tflite"
QUANTIZE = True  # Enable quantization for smaller model size


def convert_to_tflite(keras_model_path: Path, output_path: Path, quantize: bool = True) -> None:
    """Convert Keras model to TFLite format with optional quantization."""
    print(f"Loading Keras model from: {keras_model_path}")
    
    if not keras_model_path.exists():
        raise FileNotFoundError(f"Model not found: {keras_model_path}")
    
    # Load the Keras model
    model = tf.keras.models.load_model(keras_model_path)
    
    print("Model loaded successfully")
    print(f"Input shape: {model.input_shape}")
    print(f"Output shape: {model.output_shape}")
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    if quantize:
        print("Applying quantization...")
        # Use dynamic range quantization (good balance of size and accuracy)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    print("Converting to TFLite...")
    tflite_model = converter.convert()
    
    # Save
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    # Get model size
    model_size_kb = len(tflite_model) / 1024
    model_size_mb = model_size_kb / 1024
    
    print(f"\nTFLite model saved to: {output_path}")
    print(f"Model size: {model_size_kb:.2f} KB ({model_size_mb:.2f} MB)")
    
    return tflite_model


def test_tflite_model(tflite_model_path: Path, input_shape: tuple = (1, 42)) -> None:
    """Test TFLite model inference with sample data."""
    print("\nTesting TFLite model inference...")
    
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=str(tflite_model_path))
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"Input details: {input_details}")
    print(f"Output details: {output_details}")
    
    # Create sample input (normalized landmarks)
    sample_input = np.random.randn(*input_shape).astype(np.float32)
    
    # Set input tensor
    interpreter.set_tensor(input_details[0]['index'], sample_input)
    
    # Run inference
    interpreter.invoke()
    
    # Get output
    output_data = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"\nSample input shape: {sample_input.shape}")
    print(f"Sample output shape: {output_data.shape}")
    print(f"Sample output: {output_data}")
    print(f"Predicted class: {np.argmax(output_data)}")
    print(f"Confidence: {np.max(output_data):.4f}")
    
    # Test with multiple samples
    print("\nTesting with 10 random samples...")
    for i in range(10):
        sample = np.random.randn(*input_shape).astype(np.float32)
        interpreter.set_tensor(input_details[0]['index'], sample)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]['index'])
        pred_class = np.argmax(output)
        confidence = np.max(output)
        print(f"  Sample {i+1}: Class {pred_class}, Confidence {confidence:.4f}")


def compare_keras_vs_tflite(keras_model_path: Path, tflite_model_path: Path, 
                           num_samples: int = 100) -> None:
    """Compare predictions between Keras and TFLite models."""
    print(f"\nComparing Keras vs TFLite models ({num_samples} samples)...")
    
    # Load Keras model
    keras_model = tf.keras.models.load_model(keras_model_path)
    
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=str(tflite_model_path))
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    matches = 0
    total_diff = 0.0
    
    for i in range(num_samples):
        # Generate random sample
        sample = np.random.randn(1, 42).astype(np.float32)
        
        # Keras prediction
        keras_pred = keras_model.predict(sample, verbose=0)
        keras_class = np.argmax(keras_pred)
        keras_conf = np.max(keras_pred)
        
        # TFLite prediction
        interpreter.set_tensor(input_details[0]['index'], sample)
        interpreter.invoke()
        tflite_pred = interpreter.get_tensor(output_details[0]['index'])
        tflite_class = np.argmax(tflite_pred)
        tflite_conf = np.max(tflite_pred)
        
        # Compare
        if keras_class == tflite_class:
            matches += 1
        
        diff = np.abs(keras_pred - tflite_pred).mean()
        total_diff += diff
    
    accuracy = matches / num_samples
    avg_diff = total_diff / num_samples
    
    print(f"Class prediction match rate: {accuracy:.2%}")
    print(f"Average output difference: {avg_diff:.6f}")
    
    if accuracy > 0.95:
        print("✓ Models are highly consistent!")
    elif accuracy > 0.80:
        print("⚠ Models show some differences (likely due to quantization)")
    else:
        print("✗ Models show significant differences - check conversion!")


def main():
    """Main conversion pipeline."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("Keras to TFLite Model Conversion")
    print("=" * 60)
    
    # Convert model
    tflite_model = convert_to_tflite(MODEL_PATH, TFLITE_MODEL_PATH, QUANTIZE)
    
    # Test inference
    test_tflite_model(TFLITE_MODEL_PATH)
    
    # Compare with Keras model
    if MODEL_PATH.exists():
        compare_keras_vs_tflite(MODEL_PATH, TFLITE_MODEL_PATH)
    
    # Copy class labels if available
    classes_path = OUTPUT_DIR / "tsl_model_classes.json"
    if classes_path.exists():
        with open(classes_path, 'r') as f:
            classes = json.load(f)
        
        # Save classes for mobile app
        mobile_classes_path = OUTPUT_DIR / "tsl_gesture_classes.json"
        with open(mobile_classes_path, 'w') as f:
            json.dump(classes, f, indent=2)
        print(f"\nClass labels saved to: {mobile_classes_path}")
    
    print("\n" + "=" * 60)
    print("Conversion complete!")
    print(f"TFLite model ready for mobile deployment: {TFLITE_MODEL_PATH}")
    print("=" * 60)


if __name__ == "__main__":
    main()

