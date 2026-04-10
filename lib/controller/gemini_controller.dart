import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:submission/model/nutrition.dart';
import 'package:submission/service/gemini_service.dart';

/// Controller for Gemini AI nutrition state.
class GeminiController extends ChangeNotifier {
  final GeminiService service;

  GeminiController(this.service);

  Nutrition? _nutrition;
  Nutrition? get nutrition => _nutrition;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetches structured nutrition data from Gemini for [foodName].
  Future<void> fetchNutrition(String foodName) async {
    _isLoading = true;
    _errorMessage = null;
    _nutrition = null;
    notifyListeners();

    try {
      _nutrition = await service.getNutrition(foodName);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('exceeded your current quota') ||
          msg.contains('limit: 0')) {
        _errorMessage = 'Gemini quota exceeded. Please try again later.';
      } else if (msg.contains('API key not valid')) {
        _errorMessage = 'Invalid Gemini API key. Check your .env configuration.';
      } else {
        _errorMessage = 'Failed to fetch nutrition data.';
      }
      log(msg, name: 'GeminiController');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the controller state.
  void clear() {
    _nutrition = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
