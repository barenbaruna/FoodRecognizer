import 'dart:convert';

/// Data class representing a meal from the MealDB API.
///
/// Parses the MealDB JSON response, including strIngredient1..20
/// and strMeasure1..20 pairs into a clean [List<Ingredient>].
class Meal {
  final String idMeal;
  final String strMeal;
  final String? strMealThumb;
  final String? strInstructions;
  final String? strCategory;
  final String? strArea;
  final List<Ingredient> ingredients;

  Meal({
    required this.idMeal,
    required this.strMeal,
    this.strMealThumb,
    this.strInstructions,
    this.strCategory,
    this.strArea,
    required this.ingredients,
  });

  /// Creates a [Meal] from a MealDB JSON map.
  factory Meal.fromMap(Map<String, dynamic> map) {
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final name = map['strIngredient$i'] as String?;
      final measure = map['strMeasure$i'] as String?;
      if (name != null && name.trim().isNotEmpty) {
        ingredients.add(Ingredient(name: name.trim(), measure: measure ?? ''));
      }
    }

    return Meal(
      idMeal: map['idMeal'] as String,
      strMeal: map['strMeal'] as String,
      strMealThumb: map['strMealThumb'] as String?,
      strInstructions: map['strInstructions'] as String?,
      strCategory: map['strCategory'] as String?,
      strArea: map['strArea'] as String?,
      ingredients: ingredients,
    );
  }

  factory Meal.fromJson(String source) =>
      Meal.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'idMeal': idMeal,
      'strMeal': strMeal,
      'strMealThumb': strMealThumb,
      'strInstructions': strInstructions,
      'strCategory': strCategory,
      'strArea': strArea,
    };
    for (int i = 0; i < ingredients.length; i++) {
      map['strIngredient${i + 1}'] = ingredients[i].name;
      map['strMeasure${i + 1}'] = ingredients[i].measure;
    }
    return map;
  }

  String toJson() => json.encode(toMap());
}

/// A single ingredient with its measurement.
class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});
}
