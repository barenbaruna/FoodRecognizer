import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/home_controller.dart';
import 'package:submission/controller/image_classification_controller.dart';
import 'package:submission/firebase_options.dart';
import 'package:submission/service/firebase_ml_service.dart';
import 'package:submission/service/image_classification_service.dart';
import 'package:submission/service/image_picker_service.dart';
import 'package:submission/service/gemini_service.dart';
import 'package:submission/service/meal_db_service.dart';
import 'package:submission/controller/gemini_controller.dart';
import 'package:submission/controller/meal_db_controller.dart';
import 'package:submission/controller/result_controller.dart';
import 'package:submission/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // Services (plain Provider).
        Provider(create: (_) => ImagePickerService()),
        Provider(create: (_) => FirebaseMlService()),
        Provider(create: (_) => GeminiService()),
        Provider(create: (_) => MealDbService()),
        Provider(
          create: (context) => ImageClassificationService(
            context.read<FirebaseMlService>(),
          ),
        ),

        // Controllers (ChangeNotifierProvider).
        ChangeNotifierProvider(
          create: (context) => HomeController(context.read<ImagePickerService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ImageClassificationController(
            context.read<ImageClassificationService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => GeminiController(context.read<GeminiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => MealDbController(context.read<MealDbService>()),
        ),
        ChangeNotifierProxyProvider3<ImageClassificationController,
            GeminiController, MealDbController, ResultController>(
          create: (context) => ResultController(
            context.read<ImageClassificationController>(),
            context.read<GeminiController>(),
            context.read<MealDbController>(),
          ),
          update: (_, ml, gemini, meal, previous) =>
              previous ?? ResultController(ml, gemini, meal),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recognizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
