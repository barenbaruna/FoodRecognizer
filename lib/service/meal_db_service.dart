import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:submission/model/meal.dart';

/// Service for fetching meal data from TheMealDB API.
class MealDbService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Searches for a recipe matching [foodName].
  ///
  /// Returns the first [Meal] match, or `null` if none found.
  Future<Meal?> searchMeal(String foodName) async {
    final uri = Uri.parse('$_baseUrl/search.php?s=$foodName');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final mealsList = data['meals'];
        if (mealsList != null && mealsList is List && mealsList.isNotEmpty) {
          return Meal.fromMap(mealsList.first);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch from MealDB: $e');
    }
  }
}
