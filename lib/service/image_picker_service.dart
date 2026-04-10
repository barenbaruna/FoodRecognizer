import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Service for picking and cropping images.
///
/// Uses [ImagePicker] for camera/gallery selection and [ImageCropper]
/// to enforce a 1:1 aspect ratio for the 224×224 model input.
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from [source] and crops it to 1:1. Returns the file path.
  Future<String?> pickAndCropImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) {
      return null;
    }

    return await _cropImage(pickedFile.path);
  }

  /// Crops the image at [imagePath] with a 1:1 aspect ratio.
  Future<String?> _cropImage(String imagePath) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 500,
      maxHeight: 500,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    return croppedFile?.path;
  }
}
