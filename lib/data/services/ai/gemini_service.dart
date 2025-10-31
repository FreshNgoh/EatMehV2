import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final Dio _dio = Dio();
  static String? get _apiKey => dotenv.env['GEMINI_API_KEY'];

  static Future<Map<String, dynamic>> analyzeMealImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestData = {
        "contents": [
          {
            "parts": [
              {
                "inlineData": {"mimeType": "image/jpeg", "data": base64Image},
              },
              {
                "text": """Analyze this meal image and provide:
1. Estimated total calories (as integer)
2. List of food items identified
3. Meal type (breakfast/lunch/dinner/snack)
4. Nutrition breakdown (protein, carbs, fat, fiber in grams)
5. Brief health recommendation (one sentence)

Return response in JSON format:
{
  "calories": 0,
  "foodItems": ["item1", "item2"],
  "mealType": "lunch",
  "nutrition": {
    "protein": 0,
    "carbs": 0,
    "fat": 0,
    "fiber": 0
  },
  "recommendation": "your recommendation here"
}""",
              },
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.1,
          "responseMimeType": "application/json",
        },
      };

      final response = await _dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
        data: requestData,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final text =
            response.data['candidates'][0]['content']['parts'][0]['text'];
        return jsonDecode(text) as Map<String, dynamic>;
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      throw Exception("Failed to analyze image: $e");
    }
  }
}
