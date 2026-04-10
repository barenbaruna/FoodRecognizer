import 'dart:developer';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:submission/service/firebase_ml_service.dart';
import 'package:submission/service/isolate_inference.dart';

/// Service orchestrating TFLite food classification inference.
///
/// Manages model loading (Firebase ML with local fallback),
/// label parsing, and background [IsolateInference] lifecycle.
class ImageClassificationService {
  final FirebaseMlService _firebaseMlService;

  static const String _labelsPath = 'assets/probability-labels-en.txt';

  late Interpreter _interpreter;
  late List<String> _labels;
  late Tensor _inputTensor;
  late Tensor _outputTensor;
  late IsolateInference _isolateInference;

  ImageClassificationService(this._firebaseMlService);

  /// Initializes labels, model, and isolate. Must be called before inference.
  Future<void> initHelper() async {
    await _loadLabels();
    await _loadModel();

    _isolateInference = IsolateInference();
    await _isolateInference.start();

    log(
      'ML pipeline initialized. Input: ${_inputTensor.shape}, '
      'Output: ${_outputTensor.shape}, Labels: ${_labels.length}',
      name: 'ImageClassificationService',
    );
  }

  /// Loads food labels from the bundled assets file.
  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(_labelsPath);
    _labels = labelTxt.split('\n');
    log('Loaded ${_labels.length} labels', name: 'ImageClassificationService');
  }

  /// Loads the TFLite model. Tries Firebase ML first, then local asset fallback.
  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    try {
      final modelFile = await _firebaseMlService.loadModel();
      _interpreter = Interpreter.fromFile(modelFile, options: options);
      log('Model loaded from Firebase ML', name: 'ImageClassificationService');
    } catch (e) {
      log(
        'Firebase ML failed ($e), falling back to local model',
        name: 'ImageClassificationService',
      );
      _interpreter = await Interpreter.fromAsset(
        'assets/model.tflite',
        options: options,
      );
      log('Model loaded from local assets', name: 'ImageClassificationService');
    }

    _inputTensor = _interpreter.getInputTensors().first;
    _outputTensor = _interpreter.getOutputTensors().first;
  }

  /// Runs inference on a real-time camera frame in a background isolate.
  Future<Map<String, double>> inferenceCameraFrame(
    CameraImage cameraImage,
  ) async {
    final isolateModel = InferenceModel(
      cameraImage: cameraImage,
      interpreterAddress: _interpreter.address,
      labels: _labels,
      inputShape: _inputTensor.shape,
      outputShape: _outputTensor.shape,
    );

    final responsePort = ReceivePort();
    _isolateInference.sendPort.send(
      isolateModel..responsePort = responsePort.sendPort,
    );

    final results = await responsePort.first;
    return results as Map<String, double>;
  }

  /// Runs inference on a static image file in a background isolate.
  Future<Map<String, double>> inferenceImage(String imagePath) async {
    final isolateModel = InferenceModel(
      imagePath: imagePath,
      interpreterAddress: _interpreter.address,
      labels: _labels,
      inputShape: _inputTensor.shape,
      outputShape: _outputTensor.shape,
    );

    final responsePort = ReceivePort();
    _isolateInference.sendPort.send(
      isolateModel..responsePort = responsePort.sendPort,
    );

    final results = await responsePort.first;
    return results as Map<String, double>;
  }

  /// Releases the background isolate and interpreter resources.
  Future<void> close() async {
    await _isolateInference.close();
    _interpreter.close();
    log('ML resources released', name: 'ImageClassificationService');
  }
}
