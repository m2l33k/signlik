import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'hand_tracker.dart';

/// GestureClassifierService manages TFLite model loading and inference
class GestureClassifierService extends ChangeNotifier {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  String? _error;
  String _status = 'Loading model...';
  
  // Prediction smoothing
  final List<List<double>> _probBuffer = [];
  static const int _maxBuffer = 8;
  static const double _minConfidence = 0.55;
  
  int? _currentPrediction;
  double _currentConfidence = 0.0;
  
  // Gesture labels - TSL 57 signs (will be loaded from assets)
  List<String> _labels = [];

  // Getters
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  String get status => _status;
  int? get currentPrediction => _currentPrediction;
  double get currentConfidence => _currentConfidence;
  String? get currentGesture => _currentPrediction != null && _currentPrediction! >= 0 
      ? _labels[_currentPrediction!] 
      : null;

  /// Initialize and load TFLite model
  Future<void> initialize() async {
    try {
      _status = 'Loading model...';
      notifyListeners();

      // Load model from assets
      final modelPath = 'assets/tsl_gesture_model.tflite';
      final modelData = await rootBundle.load(modelPath);
      final modelBytes = modelData.buffer.asUint8List();

      // Create interpreter
      _interpreter = Interpreter.fromBuffer(modelBytes);
      
      // Get input/output details
      final inputDetails = _interpreter!.getInputDetails();
      final outputDetails = _interpreter!.getOutputDetails();
      
      debugPrint('Model loaded successfully');
      debugPrint('Input: ${inputDetails[0]}');
      debugPrint('Output: ${outputDetails[0]}');

      // Load class labels
      await _loadLabels();

      _isLoaded = true;
      _error = null;
      _status = 'Model Ready';
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load model: $e';
      _isLoaded = false;
      _status = 'Model Error';
      debugPrint('Error loading model: $e');
      notifyListeners();
    }
  }

  /// Load gesture class labels from assets
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/tsl_gesture_classes.json');
      _labels = List<String>.from(jsonDecode(labelsData));
      debugPrint('Loaded ${_labels.length} TSL gesture labels');
    } catch (e) {
      debugPrint('Could not load TSL labels, using empty list: $e');
      _labels = [];
    }
  }

  /// Predict gesture from landmarks
  /// Input: 42 features (21 landmarks × 2 coordinates), normalized relative to wrist
  Future<int?> predictGesture(List<Point2D>? landmarks) async {
    if (!_isLoaded || _interpreter == null) {
      return null;
    }

    if (landmarks == null || landmarks.length < 21) {
      _currentPrediction = null;
      _currentConfidence = 0.0;
      notifyListeners();
      return null;
    }

    try {
      // Convert landmarks to 42-feature array (normalized relative to wrist)
      final features = _landmarksToFeatures(landmarks);
      
      // Prepare input tensor
      final input = [features];
      final inputTensor = Float32List.fromList(features);
      
      // Prepare output tensor (57 classes for TSL)
      final numClasses = _labels.length > 0 ? _labels.length : 57;
      final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);
      
      // Run inference
      _interpreter!.run([inputTensor], output);
      
      // Get probabilities
      final probs = output[0] as List<double>;
      
      // Add to smoothing buffer
      _probBuffer.add(List.from(probs));
      if (_probBuffer.length > _maxBuffer) {
        _probBuffer.removeAt(0);
      }
      
      // Average probabilities across buffer
      final avgProbs = _averageProbabilities();
      
      // Find max confidence
      double maxProb = 0.0;
      int maxIndex = 0;
      for (int i = 0; i < avgProbs.length; i++) {
        if (avgProbs[i] > maxProb) {
          maxProb = avgProbs[i];
          maxIndex = i;
        }
      }
      
      // Apply confidence threshold
      if (maxProb < _minConfidence) {
        _currentPrediction = null;
        _currentConfidence = 0.0;
      } else {
        _currentPrediction = maxIndex;
        _currentConfidence = maxProb;
      }
      
      notifyListeners();
      return _currentPrediction;
    } catch (e) {
      debugPrint('Prediction error: $e');
      _currentPrediction = null;
      _currentConfidence = 0.0;
      notifyListeners();
      return null;
    }
  }

  /// Convert landmarks to 42-feature array
  List<double> _landmarksToFeatures(List<Point2D> landmarks) {
    // Landmarks should already be normalized relative to wrist
    // But we'll ensure they are
    final wrist = landmarks[0];
    final features = <double>[];
    
    for (final point in landmarks) {
      features.add(point.x - wrist.x);
      features.add(point.y - wrist.y);
    }
    
    // Ensure we have exactly 42 features
    while (features.length < 42) {
      features.add(0.0);
    }
    
    return features.take(42).toList();
  }

  /// Average probabilities across smoothing buffer
  List<double> _averageProbabilities() {
    if (_probBuffer.isEmpty) {
      final numClasses = _labels.length > 0 ? _labels.length : 57;
      return List.filled(numClasses, 0.0);
    }
    
    final numClasses = _probBuffer[0].length;
    final avg = List.filled(numClasses, 0.0);
    for (final probs in _probBuffer) {
      for (int i = 0; i < probs.length && i < avg.length; i++) {
        avg[i] += probs[i];
      }
    }
    
    final count = _probBuffer.length;
    for (int i = 0; i < avg.length; i++) {
      avg[i] /= count;
    }
    
    return avg;
  }

  /// Dispose resources
  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}

extension ListExtension on List {
  List reshape(List<int> shape) {
    // Simple reshape helper for output tensor
    return this;
  }
}

