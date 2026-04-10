import 'package:flutter/material.dart';
import 'package:submission/model/meal.dart';

/// Card displaying a meal recipe from TheMealDB.
///
/// Renders meal name, photo, ingredients, and cooking instructions.
class RecipeCard extends StatelessWidget {
  final Meal meal;

  const RecipeCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header.
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meal.strMeal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (meal.strArea != null || meal.strCategory != null)
              Text(
                '${meal.strArea ?? ''} ${meal.strCategory ?? ''}'.trim(),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 12),

            // Meal photo.
            if (meal.strMealThumb != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.strMealThumb!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (meal.strMealThumb != null) const SizedBox(height: 16),

            // Ingredients.
            const Text(
              'Ingredients:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map(
              (ing) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text('${ing.name} - ${ing.measure}'),
                    ),
                  ],
                ),
              ),
            ),

            // Cooking instructions.
            if (meal.strInstructions != null &&
                meal.strInstructions!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                meal.strInstructions!,
                style: const TextStyle(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
