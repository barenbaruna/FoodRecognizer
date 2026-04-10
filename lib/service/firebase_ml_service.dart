import 'dart:developer';
import 'dart:io';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

/// Service for downloading the ML model from Firebase ML Console.
///
/// Downloads the "food-classifier" model and returns a local [File] reference.
class FirebaseMlService {
  static const String _modelName = 'food-classifier';

  /// Downloads the food classifier model from Firebase ML.
  ///
  /// Uses [FirebaseModelDownloadType.localModel] to prefer cached version.
  Future<File> loadModel() async {
    log('Downloading model "$_modelName" from Firebase ML...',
        name: 'FirebaseMlService');

    final model = await FirebaseModelDownloader.instance.getModel(
      _modelName,
      FirebaseModelDownloadType.localModel,
      FirebaseModelDownloadConditions(
        iosAllowsCellularAccess: true,
        iosAllowsBackgroundDownloading: false,
        androidChargingRequired: false,
        androidWifiRequired: false,
        androidDeviceIdleRequired: false,
      ),
    );

    log('Model downloaded successfully: ${model.file.path}',
        name: 'FirebaseMlService');
    return model.file;
  }
}
