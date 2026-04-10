# Food Recognizer App

Welcome to **Food Recognizer**! This is a simple, smart, and fast Flutter app that helps you identify food from your camera or photo gallery. 

Built with modern Flutter architecture, it combines **on-device Machine Learning** (TensorFlow Lite / LiteRT) for instant food recognition with **Gemini AI** to estimate nutritional values. It also uses **TheMealDB** to fetch recipes for the food it spots.

## Features

- **Real-time Camera AI:** See what food is on your screen instantly.
- **Gallery & Photo Capture:** Upload an existing photo or snap a new one.
- **Nutrition Estimation:** Automatically fetch calories, carbs, protein, fat, and fiber using Gemini 2.0 Flash.
- **Get the Recipe:** Pulls cooking instructions and ingredients directly from TheMealDB.
- **Fast & Private:** Image recognition runs entirely on your device (no internet needed to guess the food!).

## Getting Started

1. **Clone the repo** and run `flutter pub get`.
2. **Environment Variables:** Create a `.env` file in the root directory and add your Gemini API key:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
3. **Generate ENV:** Run the build runner to generate the secure environment variable parser:
   ```bash
   dart run build_runner build -d
   ```
4. **Run the App:** 
   ```bash
   flutter run
   ```

## Tech Stack

- **Framework:** Flutter (Provider for State Management)
- **Machine Learning:** `flutter_litert` with Firebase ML custom models
- **AI Integration:** `google_generative_ai` (Gemini 2.0)
- **APIs:** TheMealDB API

