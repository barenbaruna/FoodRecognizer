import 'package:flutter/material.dart';
import 'package:submission/model/nutrition.dart';

/// Card displaying estimated nutritional information from Gemini AI.
class NutritionCard extends StatelessWidget {
  final Nutrition nutrition;

  const NutritionCard({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_weight, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  'Estimated Nutrition (1 Portion)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow('Calories', '${nutrition.kalori} kcal'),
            _infoRow('Carbs', '${nutrition.karbohidrat} g'),
            _infoRow('Fat', '${nutrition.lemak} g'),
            _infoRow('Fiber', '${nutrition.serat} g'),
            _infoRow('Protein', '${nutrition.protein} g'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
