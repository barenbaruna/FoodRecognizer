import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:submission/env/env.dart';
import 'package:submission/model/nutrition.dart';

/// Service for fetching structured nutrition data from Gemini AI.
///
/// Uses `gemini-2.0-flash` with a strict JSON schema to return
/// deterministic nutritional values (kalori, karbohidrat, lemak, serat, protein).
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = Env.geminiApiKey;

    final nutritionSchema = Schema(
      SchemaType.object,
      requiredProperties: ['kalori', 'karbohidrat', 'lemak', 'serat', 'protein'],
      properties: {
        'kalori': Schema(SchemaType.number, description: 'Kalori dalam kcal'),
        'karbohidrat': Schema(SchemaType.number, description: 'Karbohidrat dalam gram'),
        'lemak': Schema(SchemaType.number, description: 'Lemak dalam gram'),
        'serat': Schema(SchemaType.number, description: 'Serat dalam gram'),
        'protein': Schema(SchemaType.number, description: 'Protein dalam gram'),
      },
    );

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: nutritionSchema,
        temperature: 0,
      ),
      systemInstruction: Content.system(
        "Saya adalah suatu mesin yang mampu mengidentifikasi nutrisi atau kandungan gizi "
        "pada makanan layaknya uji laboratorium makanan. Hal yang bisa diidentifikasi "
        "adalah kalori, karbohidrat, lemak, serat, dan protein pada makanan. "
        "Satuan dari indikator tersebut berupa gram.",
      ),
    );
  }

  /// Returns structured [Nutrition] data for [foodName].
  Future<Nutrition> getNutrition(String foodName) async {
    final content = Content.text("Nama makanannya adalah $foodName.");
    final response = await _model.generateContent([content]);

    if (response.text == null || response.text!.isEmpty) {
      throw Exception('Gemini returned empty response for $foodName');
    }

    return Nutrition.fromJson(response.text!);
  }
}
