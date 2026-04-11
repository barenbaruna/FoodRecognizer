import 'package:flutter/widgets.dart';
import 'package:submission/controller/gemini_controller.dart';
import 'package:submission/controller/image_classification_controller.dart';
import 'package:submission/controller/meal_db_controller.dart';

/// Orchestrator for the Result Page workflow.
///
/// Coordinates ML classification, Gemini nutrition, and MealDB recipe
/// fetching in a sequential-then-concurrent pipeline.
class ResultController extends ChangeNotifier {
  final ImageClassificationController _mlController;
  final GeminiController _geminiController;
  final MealDbController _mealDbController;

  ResultController(
    this._mlController,
    this._geminiController,
    this._mealDbController,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _loadingMessage = '';
  String get loadingMessage => _loadingMessage;

  bool _isNotFood = false;
  bool get isNotFood => _isNotFood;

  /// Runs the full analysis pipeline:
  /// 1. Classifies the image via ML.
  /// 2. Fetches nutrition and recipe data concurrently.
  Future<void> analyzeAndFetch(String imagePath) async {
    _isLoading = true;
    _loadingMessage = 'Classifying image...';
    notifyListeners();

    _mlController.clearResults();
    _geminiController.clear();
    _mealDbController.clear();

    await _mlController.classifyImage(imagePath);

    final topResult = _mlController.topResult;

    if (topResult != null) {
      if (topResult.confidence < 0.15) {
        _isNotFood = true;
      } else {
        _loadingMessage = 'Fetching data for ${topResult.foodName}...';
        notifyListeners();

        await Future.wait([
          _geminiController.fetchNutrition(topResult.foodName),
          _mealDbController.fetchMeal(topResult.foodName),
        ]);
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}
