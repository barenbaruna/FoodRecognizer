import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/image_classification_controller.dart';
import 'package:submission/controller/gemini_controller.dart';
import 'package:submission/controller/meal_db_controller.dart';
import 'package:submission/controller/result_controller.dart';
import 'package:submission/widget/classification_item.dart';
import 'package:submission/widget/nutrition_card.dart';
import 'package:submission/widget/recipe_card.dart';

/// Displays ML inference results, nutrition data, and recipe information.
class ResultPage extends StatelessWidget {
  final String imagePath;

  const ResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Result Page'),
      ),
      body: SafeArea(child: _ResultBody(imagePath: imagePath)),
    );
  }
}

class _ResultBody extends StatefulWidget {
  final String imagePath;

  const _ResultBody({required this.imagePath});

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  @override
  void initState() {
    super.initState();
    final resultController = context.read<ResultController>();
    Future.microtask(() => resultController.analyzeAndFetch(widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResultController>(
      builder: (context, resultController, _) {
        if (resultController.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  resultController.loadingMessage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Captured image.
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                        height: 250,
                      ),
                    ),
                  ),

                  // Classification results.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Consumer<ImageClassificationController>(
                      builder: (context, controller, _) {
                        return _buildClassificationSection(controller);
                      },
                    ),
                  ),

                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Divider(),
                  ),

                  // Nutrition (Gemini).
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Consumer<GeminiController>(
                      builder: (context, controller, _) {
                        return _buildNutritionSection(controller);
                      },
                    ),
                  ),

                  // Recipe (MealDB).
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Consumer<MealDbController>(
                      builder: (context, controller, _) {
                        return _buildRecipeSection(controller);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassificationSection(ImageClassificationController controller) {
    if (controller.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          controller.errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    final results = controller.classificationResults;
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No classification results. Try another image.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Classification Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...results.map(
          (result) => ClassificatioinItem(
            item: result.foodName,
            value: result.confidencePercent,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSection(GeminiController controller) {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          controller.errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (controller.nutrition != null) {
      return NutritionCard(nutrition: controller.nutrition!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildRecipeSection(MealDbController controller) {
    if (controller.isLoading) {
      return const SizedBox.shrink();
    }

    if (controller.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          controller.errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (controller.meal != null) {
      return RecipeCard(meal: controller.meal!);
    }

    if (controller.mealNotFound) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Recipe info not found for this food in TheMealDB.'),
      );
    }

    return const SizedBox.shrink();
  }
}
