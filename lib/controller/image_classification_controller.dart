import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:submission/model/classification_result.dart';
import 'package:submission/service/image_classification_service.dart';

/// Controller managing ML inference state for the UI layer.
///
/// Wraps [ImageClassificationService] with loading, error, and result states.
/// Supports both static image and real-time camera frame inference.
class ImageClassificationController extends ChangeNotifier {
  final ImageClassificationService _service;

  ImageClassificationController(this._service);

  Map<String, double> _results = {};
  Map<String, double> get results => _results;

  bool _isModelLoaded = false;
  bool get isModelLoaded => _isModelLoaded;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Returns the highest-confidence classification result.
  ClassificationResult? get topResult {
    if (_results.isEmpty) return null;
    final top = _results.entries.first;
    return ClassificationResult(foodName: top.key, confidence: top.value);
  }

  /// Returns all classification results as [ClassificationResult] objects.
  List<ClassificationResult> get classificationResults {
    return _results.entries
        .map((e) => ClassificationResult(foodName: e.key, confidence: e.value))
        .toList();
  }

  /// Initializes the ML model pipeline. Called lazily on first use.
  Future<void> _ensureModelLoaded() async {
    if (_isModelLoaded) return;

    try {
      await _service.initHelper();
      _isModelLoaded = true;
      log('Model initialization complete', name: 'ImageClassificationController');
    } catch (e) {
      _errorMessage = 'Failed to initialize ML model: $e';
      log(_errorMessage!, name: 'ImageClassificationController');
    }
  }

  /// Runs inference on a static image file.
  Future<void> classifyImage(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _ensureModelLoaded();

    if (!_isModelLoaded) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _results = await _service.inferenceImage(imagePath);
      log(
        'Classification complete: ${topResult?.foodName} (${topResult?.confidencePercent})',
        name: 'ImageClassificationController',
      );
    } catch (e) {
      _errorMessage = 'Inference failed: $e';
      log(_errorMessage!, name: 'ImageClassificationController');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Runs inference on a real-time camera frame.
  ///
  /// Does not set [isLoading] to avoid excessive rebuilds during streaming.
  Future<void> classifyCameraFrame(CameraImage cameraImage) async {
    if (!_isModelLoaded) {
      await _ensureModelLoaded();
      if (!_isModelLoaded) return;
    }

    try {
      _results = await _service.inferenceCameraFrame(cameraImage);
      notifyListeners();
    } catch (e) {
      log('Camera frame inference error: $e', name: 'ImageClassificationController');
    }
  }

  /// Clears current classification results.
  void clearResults() {
    _results = {};
    _errorMessage = null;
    notifyListeners();
  }

  /// Releases ML resources.
  Future<void> closeService() async {
    await _service.close();
    log('ML service closed', name: 'ImageClassificationController');
  }
}
