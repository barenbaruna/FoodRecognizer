import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/ui/result_page.dart';
import 'package:submission/ui/camera_stream_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  void _showImageSourceDialog(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.blue),
                title: const Text('Real-time AI Camera'),
                subtitle: const Text('Advanced mode with live ML stream'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraStreamPage()),
                  );
                  if (file != null) {
                    controller.setImagePath(file.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                subtitle: const Text('Capture and crop (1:1)'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await controller.pickAndCropImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select existing photo and crop'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await controller.pickAndCropImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceDialog(context, controller),
                  child: controller.hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(controller.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.image, size: 100),
                        ),
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: controller.hasImage
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultPage(
                            imagePath: controller.imagePath!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text("Analyze"),
            ),
          ],
        );
      },
    );
  }
}
