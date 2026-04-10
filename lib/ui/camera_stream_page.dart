import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/image_classification_controller.dart';
import 'package:submission/widget/camera_view.dart';

/// Full-screen camera page with real-time ML classification overlay.
///
/// Streams camera frames to [ImageClassificationController] for live inference
/// and displays the top result as a floating overlay. The user can capture
/// the current frame via the shutter button, which pops the page and returns
/// the captured [XFile].
class CameraStreamPage extends StatefulWidget {
  const CameraStreamPage({super.key});

  @override
  State<CameraStreamPage> createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  CameraController? _cameraController;

  @override
  void dispose() {
    try {
      context.read<ImageClassificationController>().clearResults();
    } catch (_) {
      // Provider may be unavailable if widget tree is already disposed.
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Real-time AI Camera'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera preview.
          Positioned.fill(
            child: CameraView(
              onControllerCreated: (controller) {
                _cameraController = controller;
              },
              onImage: (image) {
                context
                    .read<ImageClassificationController>()
                    .classifyCameraFrame(image);
              },
            ),
          ),

          // Live classification result overlay.
          Positioned(
            top: 24,
            left: 16,
            right: 16,
            child: Consumer<ImageClassificationController>(
              builder: (context, controller, child) {
                final topResult = controller.topResult;
                if (topResult == null) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          topResult.foodName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        topResult.confidencePercent,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Capture button.
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_cameraController != null &&
                        _cameraController!.value.isInitialized) {
                      try {
                        final file = await _cameraController!.takePicture();
                        if (context.mounted) {
                          Navigator.pop(context, file);
                        }
                      } catch (e) {
                        debugPrint('Error taking picture: $e');
                      }
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        height: 64,
                        width: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
