import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:image/image.dart' as img_lib;
import 'package:submission/utils/image_utils.dart';

/// Data transfer object for sending inference data to a background [Isolate].
///
/// Carries the image data, interpreter address, labels, and tensor shapes
/// needed to perform inference independently in the isolate.
class InferenceModel {
  CameraImage? cameraImage;
  String? imagePath;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel({
    this.cameraImage,
    this.imagePath,
    required this.interpreterAddress,
    required this.labels,
    required this.inputShape,
    required this.outputShape,
  });
}

/// Manages a persistent background [Isolate] for running TFLite inference.
///
/// The isolate stays alive across multiple inference calls, avoiding
/// the overhead of spawning a new isolate per frame.
class IsolateInference {
  static const String _debugName = 'TFLITE_INFERENCE';
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  /// Spawns the background isolate and establishes communication.
  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      _entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first as SendPort;
  }

  /// Isolate entry point. Listens for [InferenceModel] messages,
  /// processes images, runs inference, and sends back results.
  static void _entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel model in port) {
      final result = _runInferenceOnModel(model);
      model.responsePort.send(result);
    }
  }

  /// Processes an [InferenceModel] and returns classification results.
  ///
  /// 1. Converts input image to [img_lib.Image].
  /// 2. Resizes to model input dimensions.
  /// 3. Converts pixel data to a flat [Uint8List] buffer.
  /// 4. Runs TFLite inference.
  /// 5. Maps output probabilities to labels, sorted by confidence.
  static Map<String, double> _runInferenceOnModel(InferenceModel model) {
    img_lib.Image? image;

    if (model.cameraImage != null) {
      image = ImageUtils.convertCameraImage(model.cameraImage!);
    } else if (model.imagePath != null) {
      final bytes = File(model.imagePath!).readAsBytesSync();
      image = img_lib.decodeImage(bytes);
    }

    if (image == null) {
      return {'Error: Unable to process image': 0.0};
    }

    // Resize to model input dimensions.
    final inputWidth = model.inputShape[2];
    final inputHeight = model.inputShape[1];
    img_lib.Image imageInput = img_lib.copyResize(
      image,
      width: inputWidth,
      height: inputHeight,
    );

    if (model.cameraImage != null && Platform.isAndroid) {
      imageInput = img_lib.copyRotate(imageInput, angle: 90);
    }

    // Convert image to a multi-dimensional nested List<int>.
    // flutter_litert natively expects a List structure (not a flat Uint8List).
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
        },
      ),
    );

    // Run inference.
    final input = [imageMatrix];
    final outputSize = model.outputShape[1];
    final output = [List<int>.filled(outputSize, 0)];

    final interpreter = Interpreter.fromAddress(model.interpreterAddress);
    interpreter.run(input, output);

    // Convert raw output to probability map.
    final result = output[0];
    int maxScore = 0;
    for (final val in result) {
      maxScore += val;
    }
    if (maxScore == 0) maxScore = 1;

    final classification = <String, double>{};
    for (int i = 0; i < result.length && i < model.labels.length; i++) {
      final label = model.labels[i].trim();
      final probability = result[i].toDouble() / maxScore.toDouble();

      if (label.isNotEmpty && label != '__background__' && probability > 0) {
        classification[label] = probability;
      }
    }

    // Sort descending and return top 5.
    final sorted = Map.fromEntries(
      classification.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
    return Map.fromEntries(sorted.entries.take(5));
  }

  /// Kills the background isolate and closes the receive port.
  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }
}
