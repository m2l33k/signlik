#!/usr/bin/env python3
"""
TSL Model Inference Script
Called from Java backend to perform gesture recognition
"""
import json
import sys
import os
import numpy as np

# Add path for TensorFlow Lite
try:
    import tflite_runtime.interpreter as tflite
except ImportError:
    try:
        import tensorflow.lite as tflite
    except ImportError:
        print("ERROR: TensorFlow Lite not installed", file=sys.stderr)
        sys.exit(1)

def load_model(model_path, classes_path):
    """Load TFLite model and classes."""
    if not os.path.exists(model_path):
        print(f"ERROR: Model not found: {model_path}", file=sys.stderr)
        sys.exit(1)
    
    if not os.path.exists(classes_path):
        print(f"ERROR: Classes file not found: {classes_path}", file=sys.stderr)
        sys.exit(1)
    
    # Load model
    interpreter = tflite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    
    # Load classes
    with open(classes_path, 'r') as f:
        classes = json.load(f)
    
    return interpreter, classes

def predict(interpreter, classes, landmarks):
    """Predict gesture from landmarks."""
    # Get input and output tensors
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    # Validate input shape
    expected_shape = input_details[0]['shape']
    if len(landmarks) != expected_shape[1]:
        print(f"ERROR: Expected {expected_shape[1]} landmarks, got {len(landmarks)}", file=sys.stderr)
        sys.exit(1)
    
    # Prepare input
    input_data = np.array([landmarks], dtype=np.float32)
    
    # Set input tensor
    interpreter.set_tensor(input_details[0]['index'], input_data)
    
    # Run inference
    interpreter.invoke()
    
    # Get output
    output_data = interpreter.get_tensor(output_details[0]['index'])
    probabilities = output_data[0]
    
    # Get prediction
    predicted_index = int(np.argmax(probabilities))
    confidence = float(probabilities[predicted_index])
    predicted_class = classes[predicted_index] if predicted_index < len(classes) else "unknown"
    
    return {
        "index": predicted_index,
        "label": predicted_class,
        "confidence": confidence,
        "all_probabilities": probabilities.tolist()
    }

def main():
    """Main function."""
    if len(sys.argv) < 3:
        print("Usage: infer_tsl.py <model_path> <classes_path> <landmarks_json>", file=sys.stderr)
        sys.exit(1)
    
    model_path = sys.argv[1]
    classes_path = sys.argv[2]
    landmarks_json = sys.argv[3]
    
    try:
        # Parse landmarks
        landmarks = json.loads(landmarks_json)
        
        if not isinstance(landmarks, list) or len(landmarks) != 42:
            print(f"ERROR: Expected list of 42 floats, got {type(landmarks)} with length {len(landmarks) if isinstance(landmarks, list) else 'N/A'}", file=sys.stderr)
            sys.exit(1)
        
        # Load model
        interpreter, classes = load_model(model_path, classes_path)
        
        # Predict
        result = predict(interpreter, classes, landmarks)
        
        # Output JSON result
        print(json.dumps(result))
        
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

