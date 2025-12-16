# TSL Model Integration Guide

## Overview

The TSL (Tunisian Sign Language) gesture recognition model has been successfully integrated into the Spring Boot backend. The model can recognize TSL gestures from hand landmarks extracted by MediaPipe.

## Architecture

### Components

1. **TSLModelService** - Core service that loads and runs the TFLite model
2. **SignToTextService** - Service that converts sign language to text (updated to use TSL model)
3. **TSLController** - REST API endpoints for gesture prediction
4. **Python Inference Script** - Python script that performs actual TFLite inference

### Flow

```
Flutter App (MediaPipe) 
  → Extracts Hand Landmarks (42 floats)
  → POST /api/tsl/predict
  → TSLController
  → SignToTextService
  → TSLModelService
  → Python Script (infer_tsl.py)
  → TFLite Model
  → Returns Predicted Gesture
```

## API Endpoints

### 1. Predict Gesture from Landmarks

**Endpoint:** `POST /api/tsl/predict`

**Request:**
```json
{
  "landmarks": [x1, y1, x2, y2, ..., x21, y21]
}
```

- `landmarks`: Array of exactly 42 floats (21 hand landmarks × 2 coordinates)
- Landmarks should be normalized (relative to wrist)

**Response:**
```json
{
  "label": "hello",
  "confidence": 0.95,
  "index": 0
}
```

**Example:**
```bash
curl -X POST http://localhost:8081/api/tsl/predict \
  -H "Content-Type: application/json" \
  -d '{
    "landmarks": [0.0, 0.0, 0.1, 0.2, ...] // 42 floats
  }'
```

### 2. Get Available Classes

**Endpoint:** `GET /api/tsl/classes`

**Response:**
```json
{
  "classes": ["hello", "goodbye", "thank_you", ...],
  "count": 10,
  "status": "ready"
}
```

### 3. Check Model Status

**Endpoint:** `GET /api/tsl/status`

**Response:**
```json
{
  "status": "ready",
  "message": "TSL Model is loaded and ready",
  "classes_count": 10
}
```

## Configuration

### application.properties

```properties
# TSL Model Configuration
tsl.model.path=classpath:models/tsl_gesture_model.tflite
tsl.classes.path=classpath:models/tsl_gesture_classes.json
tsl.python.script=classpath:python/infer_tsl.py
tsl.python.command=python3
```

### Requirements

1. **Python 3** with TensorFlow Lite installed:
   ```bash
   pip install tflite-runtime
   # OR
   pip install tensorflow
   ```

2. **Model Files** (already included in resources):
   - `src/main/resources/models/tsl_gesture_model.tflite`
   - `src/main/resources/models/tsl_gesture_classes.json`
   - `src/main/resources/python/infer_tsl.py`

## Integration with Message System

The TSL model is integrated with the existing message conversion system:

### Automatic Conversion

When a SIGN message is created, the `ModalityConversionService` will:
1. Call `SignToTextService.convertToText(videoFileUrl)`
2. Store the transcript in the message entity
3. Update conversion status (PENDING → PROCESSING → COMPLETED)

### Direct Landmark Prediction

For real-time gesture recognition (from Flutter app):

1. Flutter app extracts landmarks using MediaPipe
2. Sends landmarks to `/api/tsl/predict`
3. Receives predicted gesture text
4. Can create a TEXT message with the predicted text

## Current Model

- **Type**: Test model (synthetic data)
- **Classes**: 10 TSL signs
- **Accuracy**: 99.90% (on test data)
- **Input**: 42 hand landmarks
- **Output**: 10-class probabilities

### Available Classes (Test Model)

1. hello
2. goodbye
3. thank_you
4. please
5. sorry
6. yes
7. no
8. maybe
9. ok
10. help

**Note**: For production, train with the actual TSL dataset to support all 57 TSL signs.

## Usage Examples

### Flutter Integration

```dart
// Extract landmarks using MediaPipe
List<double> landmarks = extractHandLandmarks(image);

// Send to backend
final response = await http.post(
  Uri.parse('http://localhost:8081/api/tsl/predict'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'landmarks': landmarks}),
);

final result = jsonDecode(response.body);
String predictedGesture = result['label'];
double confidence = result['confidence'];
```

### Java Service Usage

```java
@Autowired
private SignToTextService signToTextService;

// Predict from landmarks
float[] landmarks = new float[42]; // ... populate landmarks
String gesture = signToTextService.predictFromLandmarks(landmarks);
```

## Troubleshooting

### Model Not Loading

1. Check Python is installed: `python3 --version`
2. Check TensorFlow Lite: `python3 -c "import tflite_runtime; print('OK')"`
3. Check model files exist in `src/main/resources/models/`
4. Check logs for initialization errors

### Low Confidence Predictions

- Ensure landmarks are normalized (relative to wrist)
- Check that all 42 values are provided
- Verify MediaPipe is detecting hands correctly
- Consider using confidence threshold (default: 0.5)

### Python Script Errors

- Ensure Python script is executable
- Check file permissions on temp files
- Verify Python path in `application.properties`
- Check logs for detailed error messages

## Future Enhancements

1. **Video Processing**: Process uploaded video files to extract landmarks
2. **Batch Prediction**: Support multiple landmarks at once
3. **Model Caching**: Cache model in memory for faster inference
4. **Native Java Implementation**: Replace Python bridge with native TensorFlow Lite Java
5. **Real-time Streaming**: Support streaming landmark predictions
6. **Model Versioning**: Support multiple model versions

## Testing

### Test Prediction Endpoint

```bash
# Test with sample landmarks
curl -X POST http://localhost:8081/api/tsl/predict \
  -H "Content-Type: application/json" \
  -d '{
    "landmarks": [0.0, 0.0, 0.1, 0.2, 0.15, 0.25, 0.2, 0.3, 0.25, 0.35, 0.3, 0.4, 0.35, 0.45, 0.4, 0.5, 0.45, 0.55, 0.5, 0.6, 0.55, 0.65, 0.6, 0.7, 0.65, 0.75, 0.7, 0.8, 0.75, 0.85, 0.8, 0.9, 0.85, 0.95, 0.9, 1.0, 0.95, 1.05, 1.0, 1.1, 1.05, 1.15]
  }'
```

### Check Status

```bash
curl http://localhost:8081/api/tsl/status
```

### Get Classes

```bash
curl http://localhost:8081/api/tsl/classes
```

## Notes

- The model uses a Python subprocess for inference (simpler than native Java implementation)
- Model files are extracted to temp directory at startup
- Python script must be executable
- Ensure Python 3 and TensorFlow Lite are installed on the server
- For production, consider using a native Java TensorFlow Lite implementation for better performance

---

**Integration Date**: December 5, 2024  
**Model Version**: Test v1.0  
**Status**: ✅ Integrated and Ready

