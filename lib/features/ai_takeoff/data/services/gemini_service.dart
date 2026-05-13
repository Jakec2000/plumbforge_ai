import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/models/takeoff_result.dart';
import '../../domain/prompts/takeoff_prompts.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'mock_key';
  return GeminiService(apiKey);
});

class GeminiService {
  final String _apiKey;
  late final GenerativeModel _model;

  GeminiService(this._apiKey) {
    if (_apiKey != 'mock_key') {
      _model = GenerativeModel(
        model: 'gemini-1.5-pro-vision-latest',
        apiKey: _apiKey,
        systemInstruction: Content.system(TakeoffPrompts.systemInstruction),
      );
    }
  }

  Future<TakeoffResult> analyzeJobSite(Uint8List imageBytes, String voiceTranscript) async {
    // If we're using a mock key, return dummy data to unblock development
    if (_apiKey == 'mock_key') {
      await Future.delayed(const Duration(seconds: 2));
      return TakeoffResult.fromJson({
        "detectedFixtures": ["Toilet (WC)", "Vanity Basin"],
        "pipeRuns": [
          {"material": "PVC-U", "estimatedLength": 2.5, "diameter": 100},
          {"material": "Copper", "estimatedLength": 4.0, "diameter": 20}
        ],
        "complianceFlags": ["AS/NZS 3500.2 Clause 6.1: Minimum pipe size for WC is 100mm."],
        "recommendedSolution": "Install new 100mm PVC-U drain with 1:60 fall connecting to existing stack."
      });
    }

    final prompt = TextPart("Voice Transcript: \$voiceTranscript\n\nPlease analyze this site image and transcript.");
    final imagePart = DataPart('image/jpeg', imageBytes);

    try {
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final responseText = response.text ?? '{}';
      
      // Clean JSON if Gemini wraps it in markdown blocks
      final jsonString = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      return TakeoffResult.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to analyze job site with Gemini: \$e');
    }
  }
}
