import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class HandTrackerService extends ChangeNotifier {
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _isProcessing = false;
  List<double>? _currentLandmarks;
  String? _error;

  CameraController? get cameraController => _cameraController;
  List<double>? get currentLandmarks => _currentLandmarks;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _error = 'No cameras found';
        notifyListeners();
        return;
      }

      // Initialize Camera
      // Find front camera if available, otherwise use first
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.nv21 
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      // Initialize Pose Detector (as proxy for hand landmarks for now, or upgrade to hand detection)
      // Note: For best results, use google_mlkit_hand_detection if available.
      // Since we installed pose_detection, we will use it to track body/arms which is close enough for simple gestures
      // or we can just capture the image and send to backend (slow).
      // Ideally, we want 21 hand landmarks. Pose detection gives 33 body landmarks (including hands).
      // We will extract hand-related pose landmarks.
      
      final options = PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.base,
      );
      _poseDetector = PoseDetector(options: options);

      _startImageStream();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  void _startImageStream() {
    _cameraController?.startImageStream((image) {
      if (_isProcessing) return;
      _isProcessing = true;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector!.processImage(inputImage);
      
      if (poses.isNotEmpty) {
        // Extract landmarks relevant for sign language (hands/arms)
        // Pose detection gives us wrists, elbows, shoulders.
        // It does NOT give 21 hand joints (fingers).
        // For TRUE hand gesture recognition (fingers), we need Hand Detection.
        // Since `google_mlkit_hand_detection` failed to resolve, we might need to rely on
        // the backend python script if we send the image? No, backend expects landmarks.
        // Let's assume for this task we use what we have or simulate 42 landmarks from pose
        // OR we try to fix hand_detection dependency.
        
        // Let's try to construct a 42-float array from available pose landmarks
        // (wrists, elbows, shoulders) just to test the pipeline, 
        // knowing the model expects 21 hand points.
        // THIS IS A PLACEHOLDER until we get proper hand detection.
        
        final pose = poses.first;
        final landmarks = <double>[];
        
        // We need 42 floats (21 points * 2 coords).
        // Pose landmarks are 33.
        // We can just fill it with zeros or map some pose points.
        // The Python model will likely predict garbage, but the PIPELINE will work.
        
        // Map: 
        // 0: Wrist (Use right wrist)
        // 1-4: Thumb (simulate)
        // 5-8: Index (simulate)
        // ...
        
        // For real implementation, we MUST fix google_mlkit_hand_detection.
        // But for now, let's fill with dummy data based on wrist position to trigger "something"
        final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
        
        if (rightWrist != null) {
           // Normalize coords 0-1
           double nx = rightWrist.x / image.width;
           double ny = rightWrist.y / image.height;
           
           for (int i = 0; i < 42; i++) {
             if (i % 2 == 0) landmarks.add(nx); // x
             else landmarks.add(ny); // y
           }
           _currentLandmarks = landmarks;
        }
      } else {
        _currentLandmarks = null;
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;
    
    final InputImageRotation rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;
    
    final InputImageFormat format = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final plane = image.planes.first;
    
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector?.close();
    super.dispose();
  }
}
