import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

class TravelRecommendationService {
  static Future<Map<String, dynamic>> generateRecommendation({
    required int tripDuration,
    required int travelBudget,
    required int participants,
    required String destination,
    required String travelType,
  }) async {
    final jsonSchema = Schema.object(
      properties: {
        'title': Schema.string(),
        'summary': Schema.string(),
        'recommendedActivities': Schema.array(
          items: Schema.string(),
        ),
        'suggestedAccommodation': Schema.string(),
        'estimatedDailyBudget': Schema.string(),
        'bestTimeToVisit': Schema.string(),
        'travelTips': Schema.array(
          items: Schema.string(),
        ),
      },
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: jsonSchema,
      ),
    );

    final prompt = '''
You are a professional travel planner.

Generate a personalised travel recommendation in valid JSON only.

Travel details:
- Destination: $destination
- Trip Duration: $tripDuration days
- Budget: RM $travelBudget
- Number of Participants: $participants
- Type of Travel: $travelType

Return JSON with this structure:
{
  "title": "string",
  "summary": "string",
  "recommendedActivities": ["string", "string", "string"],
  "suggestedAccommodation": "string",
  "estimatedDailyBudget": "string",
  "bestTimeToVisit": "string",
  "travelTips": ["string", "string", "string"]
}
''';

    final response = await model.generateContent([
      Content.text(prompt),
    ]);

    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('No recommendation returned from Firebase AI Logic.');
    }

    final decoded = jsonDecode(text);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid JSON format returned.');
    }

    return decoded;
  }
}