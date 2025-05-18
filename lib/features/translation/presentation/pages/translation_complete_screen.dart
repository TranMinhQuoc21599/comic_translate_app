import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../shared/services/aistudio_service.dart';

class TranslationBatchCompleteScreen extends StatelessWidget {
  final List<TranslationResult> results;
  final VoidCallback onDone;

  const TranslationBatchCompleteScreen({
    Key? key,
    required this.results,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Translation Complete',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: results.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 32.0),
        itemBuilder: (context, index) {
          if (index == results.length) {
            return ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            );
          }
          final result = results[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(result.imagePath),
                  fit: BoxFit.contain,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  result.translatedText,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TranslationResult {
  final String imagePath;
  final String translatedText;
  TranslationResult({required this.imagePath, required this.translatedText});
}

class TranslationResultOverlayScreen extends StatelessWidget {
  final String imagePath;
  final List<TextRegion> regions;
  final VoidCallback onDone;

  const TranslationResultOverlayScreen({
    Key? key,
    required this.imagePath,
    required this.regions,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Complete'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Image.file(File(imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity),
          ...regions.map((region) => Positioned(
                left: region.boundingBox.left,
                top: region.boundingBox.top,
                width: region.boundingBox.width,
                height: region.boundingBox.height,
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.black.withOpacity(0.4),
                  child: Text(
                    region.translatedText ?? '',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
