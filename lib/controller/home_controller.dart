import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:submission/service/image_picker_service.dart';

/// Controller managing image selection state on the home page.
///
/// Receives [ImagePickerService] via constructor injection.
/// Tracks the currently selected image path for display and inference.
class HomeController extends ChangeNotifier {
  final ImagePickerService _imagePickerService;

  HomeController(this._imagePickerService);

  String? _imagePath;
  String? get imagePath => _imagePath;

  /// Whether an image has been selected or captured.
  bool get hasImage => _imagePath != null;

  /// Updates the selected image path and notifies listeners.
  void setImagePath(String? path) {
    _imagePath = path;
    notifyListeners();
  }

  /// Picks an image from [source], crops it, and updates state.
  Future<void> pickAndCropImage(ImageSource source) async {
    final path = await _imagePickerService.pickAndCropImage(source);
    if (path != null) {
      setImagePath(path);
    }
  }

  /// Clears the selected image.
  void clearImage() {
    _imagePath = null;
    notifyListeners();
  }
}
