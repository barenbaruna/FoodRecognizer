import 'package:camera/camera.dart';
import 'package:image/image.dart' as img_lib;

/// Utility class for converting [CameraImage] frames to [img_lib.Image].
///
/// Handles platform-specific camera formats:
/// - Android: YUV420, NV21
/// - iOS: BGRA8888
/// - Universal: JPEG
class ImageUtils {
  /// Dispatches to the correct conversion based on [CameraImage.format].
  static img_lib.Image? convertCameraImage(CameraImage cameraImage) {
    return switch (cameraImage.format.group) {
      ImageFormatGroup.nv21 => _convertNV21ToImage(cameraImage),
      ImageFormatGroup.yuv420 => _convertYUV420ToImage(cameraImage),
      ImageFormatGroup.bgra8888 => _convertBGRA8888ToImage(cameraImage),
      ImageFormatGroup.jpeg => _convertJPEGToImage(cameraImage),
      _ => null,
    };
  }

  /// Converts NV21 format (Android) to RGB image.
  static img_lib.Image _convertNV21ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final yPlane = cameraImage.planes[0];
    final uvPlane = cameraImage.planes[1];

    final image = img_lib.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvIndex = (y ~/ 2) * uvPlane.bytesPerRow + (x ~/ 2) * 2;

        final yValue = yPlane.bytes[yIndex];
        final vValue = uvPlane.bytes[uvIndex];
        final uValue = uvPlane.bytes[uvIndex + 1];

        final rgb = _yuvToRgb(yValue, uValue, vValue);
        image.setPixelRgb(x, y, rgb[0], rgb[1], rgb[2]);
      }
    }

    return image;
  }

  /// Converts YUV420 format (Android) to RGB image.
  static img_lib.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    final image = img_lib.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvRowStride = uPlane.bytesPerRow;
        final uvPixelStride = uPlane.bytesPerPixel ?? 1;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yValue = yPlane.bytes[yIndex];
        final uValue = uPlane.bytes[uvIndex];
        final vValue = vPlane.bytes[uvIndex];

        final rgb = _yuvToRgb(yValue, uValue, vValue);
        image.setPixelRgb(x, y, rgb[0], rgb[1], rgb[2]);
      }
    }

    return image;
  }

  /// Converts BGRA8888 format (iOS) to RGB image.
  static img_lib.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final plane = cameraImage.planes[0];

    final image = img_lib.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * plane.bytesPerRow + x * 4;
        final b = plane.bytes[index];
        final g = plane.bytes[index + 1];
        final r = plane.bytes[index + 2];
        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return image;
  }

  /// Converts JPEG format to RGB image.
  static img_lib.Image? _convertJPEGToImage(CameraImage cameraImage) {
    return img_lib.decodeJpg(cameraImage.planes[0].bytes);
  }

  /// Converts YUV color values to RGB using BT.601 standard.
  static List<int> _yuvToRgb(int y, int u, int v) {
    final yVal = y.toDouble();
    final uVal = u.toDouble() - 128;
    final vVal = v.toDouble() - 128;

    final r = (yVal + 1.402 * vVal).round().clamp(0, 255);
    final g = (yVal - 0.344136 * uVal - 0.714136 * vVal).round().clamp(0, 255);
    final b = (yVal + 1.772 * uVal).round().clamp(0, 255);

    return [r, g, b];
  }
}
