import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Camera preview widget with real-time image stream support.
///
/// Manages [CameraController] lifecycle including app pause/resume handling
/// via [WidgetsBindingObserver]. Streams frames through [onImage] callback.
class CameraView extends StatefulWidget {
  final Function(CameraImage cameraImage)? onImage;
  final Function(CameraController controller)? onControllerCreated;

  const CameraView({
    super.key,
    this.onImage,
    this.onControllerCreated,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  bool _isCameraInitialized = false;
  CameraController? _controller;
  bool _isProcessing = false;
  late CameraDescription _cameraDescription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  /// Safely stops the image stream and disposes the camera controller.
  void _disposeCamera() {
    final controller = _controller;
    if (controller == null) return;

    try {
      if (controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
      controller.dispose();
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
    _controller = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera(_cameraDescription);
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _cameraDescription = cameras.first;
      await _startCamera(_cameraDescription);
    } catch (e) {
      debugPrint('Error initializing available cameras: $e');
    }
  }

  Future<void> _startCamera(CameraDescription cameraDescription) async {
    _disposeCamera();

    final newController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await newController.initialize();
      if (!mounted) {
        newController.dispose();
        return;
      }

      _cameraDescription = cameraDescription;

      setState(() {
        _controller = newController;
        _isCameraInitialized = true;
      });

      if (widget.onControllerCreated != null) {
        widget.onControllerCreated!(newController);
      }

      if (widget.onImage != null) {
        newController.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
      newController.dispose();
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      if (widget.onImage != null) {
        await widget.onImage!(image);
      }
    } catch (e) {
      debugPrint('Error processing camera image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_controller!);
  }
}
