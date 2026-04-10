import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:submission/model/meal.dart';
import 'package:submission/service/meal_db_service.dart';

/// Controller for MealDB API state.
class MealDbController extends ChangeNotifier {
  final MealDbService service;

  MealDbController(this.service);

  Meal? _meal;
  Meal? get meal => _meal;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _mealNotFound = false;
  bool get mealNotFound => _mealNotFound;

  /// Fetches a meal recipe from TheMealDB for [foodName].
  Future<void> fetchMeal(String foodName) async {
    _isLoading = true;
    _errorMessage = null;
    _meal = null;
    _mealNotFound = false;
    notifyListeners();

    try {
      final fetchedMeal = await service.searchMeal(foodName);
      if (fetchedMeal != null) {
        _meal = fetchedMeal;
      } else {
        _mealNotFound = true;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch recipe from MealDB.';
      log(_errorMessage!, name: 'MealDbController');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the controller state.
  void clear() {
    _meal = null;
    _errorMessage = null;
    _mealNotFound = false;
    _isLoading = false;
    notifyListeners();
  }
}
