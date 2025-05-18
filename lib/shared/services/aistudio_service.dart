import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TextRegion {
  final Rect boundingBox;
  final String text;
  String? translatedText;
  TextRegion(
      {required this.boundingBox, required this.text, this.translatedText});
}

class AiStudioService {
  static const String _apiKey = 'AIzaSyD_QAD_j31aRqceihDbpbtIcywqZGjNYHU';
  static const String _visionEndpoint =
      'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';
  static const String _translateEndpoint =
      'https://translation.googleapis.com/language/translate/v2?key=$_apiKey';

  /// Extracts text regions (with bounding boxes) from an image using Google Vision API.
  Future<List<TextRegion>> extractTextRegionsFromImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final requestPayload = {
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION'}
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse(_visionEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    final List<TextRegion> regions = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = data['responses'] as List<dynamic>;
      final textAnnotations = responses[0]['textAnnotations'] as List<dynamic>?;
      if (textAnnotations?.isNotEmpty == true) {
        // The first annotation is the full text, skip it
        for (int i = 1; i < textAnnotations!.length; i++) {
          final ann = textAnnotations[i] as Map<String, dynamic>;
          final vertices = ann['boundingPoly']['vertices'] as List<dynamic>;
          if (vertices.length >= 2) {
            final left = (vertices[0]['x'] as num?)?.toDouble() ?? 0.0;
            final top = (vertices[0]['y'] as num?)?.toDouble() ?? 0.0;
            final right = (vertices[2]['x'] as num?)?.toDouble() ?? 0.0;
            final bottom = (vertices[2]['y'] as num?)?.toDouble() ?? 0.0;
            final rect = Rect.fromLTRB(left, top, right, bottom);
            regions.add(TextRegion(
              boundingBox: rect,
              text: ann['description'] as String,
            ));
          }
        }
      }
    }
    return regions;
  }

  /// Translates a list of text regions to Vietnamese.
  Future<List<TextRegion>> translateTextRegionsToVietnamese(
      List<TextRegion> regions) async {
    for (final region in regions) {
      region.translatedText = await translateToVietnamese(region.text);
    }
    return regions;
  }

  /// Translates text to Vietnamese using Google Translate API.
  Future<String?> translateToVietnamese(String text) async {
    final requestPayload = {
      'q': text,
      'target': 'vi',
    };

    final response = await http.post(
      Uri.parse(_translateEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translations = data['data']['translations'] as List<dynamic>?;
      if (translations?.isNotEmpty == true) {
        return translations![0]['translatedText'] as String;
      }
    }
    return null;
  }
}
