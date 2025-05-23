import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';

/// A service class that handles translations using the Gemini AI API.
/// This service provides methods for translating text and analyzing images for translation.
class GeminiService {
  static const String _apiKey = 'AIzaSyDjxmnA1J2lYpD-ouw-9HAtQ-2n7UZp1bI';
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Translates text from one language to another.
  /// [text] is the text to translate
  /// [sourceLanguage] is the source language (e.g., 'Japanese', 'English')
  /// [targetLanguage] is the target language (e.g., 'Vietnamese', 'English')
  /// Returns the translated text or throws an exception if the translation fails.
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final prompt = '''
Translate the following text from $sourceLanguage to $targetLanguage.
Maintain the original meaning and context.
If there are any cultural references, try to adapt them appropriately.
Text to translate: $text
''';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Translation failed';
    } catch (e) {
      throw Exception('Failed to translate text: $e');
    }
  }

  /// Translates text from an image.
  /// [imageBytes] is the image data in bytes
  /// [sourceLanguage] is the source language of the text in the image
  /// [targetLanguage] is the target language for translation
  /// Returns the translated text or throws an exception if the translation fails.
  Future<String> translateImageText({
    required Uint8List imageBytes,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final prompt = '''
Extract and translate all text from this image from $sourceLanguage to $targetLanguage.
Maintain the original meaning and context.
If there are any cultural references, try to adapt them appropriately.
Format the output as a list of translations, with each line showing the original text and its translation.

Show the text in image and the translation in Vietnamese fomat like this:
Text: <text>
Translation: <translation>

If the text is not in the image, return "No text found".
Delete text on image, change by translation.
''';
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];
      final response = await _visionModel.generateContent(content);
      return response.text ?? 'Translation failed';
    } catch (e) {
      throw Exception('Failed to translate image text: $e');
    }
  }
}
