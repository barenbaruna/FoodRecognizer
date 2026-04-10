import 'dart:convert';

/// Data class for nutritional information returned by the Gemini API.
///
/// All values are in grams, except [kalori] which is in kcal.
/// Field names match the Gemini structured output schema.
class Nutrition {
  final double kalori;
  final double karbohidrat;
  final double lemak;
  final double serat;
  final double protein;

  Nutrition({
    required this.kalori,
    required this.karbohidrat,
    required this.lemak,
    required this.serat,
    required this.protein,
  });

  /// Creates a [Nutrition] from a JSON map.
  ///
  /// Uses `(map['key'] as num).toDouble()` to handle both int and double.
  factory Nutrition.fromMap(Map<String, dynamic> map) {
    return Nutrition(
      kalori: (map['kalori'] as num).toDouble(),
      karbohidrat: (map['karbohidrat'] as num).toDouble(),
      lemak: (map['lemak'] as num).toDouble(),
      serat: (map['serat'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'kalori': kalori,
      'karbohidrat': karbohidrat,
      'lemak': lemak,
      'serat': serat,
      'protein': protein,
    };
  }

  factory Nutrition.fromJson(String source) =>
      Nutrition.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());
}
