/// Data class representing a food classification result.
class ClassificationResult {
  final String foodName;
  final double confidence;

  ClassificationResult({required this.foodName, required this.confidence});

  /// Confidence as a formatted percentage string.
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(2)}%';
}
