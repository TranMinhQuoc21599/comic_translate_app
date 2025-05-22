import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../shared/services/gemini_service.dart';

class TextRegion {
  final Rect boundingBox;
  final String? translatedText;

  TextRegion({
    required this.boundingBox,
    this.translatedText,
  });
}

class TranslationBatchCompleteScreen extends StatefulWidget {
  final List<TranslationResult> results;
  final VoidCallback onDone;

  const TranslationBatchCompleteScreen({
    Key? key,
    required this.results,
    required this.onDone,
  }) : super(key: key);

  @override
  State<TranslationBatchCompleteScreen> createState() =>
      _TranslationBatchCompleteScreenState();
}

class _TranslationBatchCompleteScreenState
    extends State<TranslationBatchCompleteScreen> {
  final GeminiService _geminiService = GeminiService();
  String _translatedText = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _translateImage();
  }

  Future<void> _translateImage() async {
    try {
      final result = widget.results.first;
      final imageFile = File(result.imagePath);
      final imageBytes = await imageFile.readAsBytes();

      final translatedText = await _geminiService.translateImageText(
        imageBytes: imageBytes,
        sourceLanguage: 'English',
        targetLanguage: 'Vietnamese',
      );

      if (mounted) {
        setState(() {
          _translatedText = translatedText;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.results.first;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onDone),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tiếng Nhật'),
            Icon(Icons.arrow_forward, size: 20),
            Text('Tiếng Việt'),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {/* TODO: Implement text-to-speech */},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Original Image
          Positioned.fill(
            child: Image.file(
              File(result.imagePath),
              fit: BoxFit.contain,
            ),
          ),
          // Translation Overlay
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi dịch: $_error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _translateImage,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          else
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.8),
                child: SingleChildScrollView(
                  child: Text(
                    _translatedText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _translateImage,
        child: const Icon(Icons.refresh),
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
                  color: Colors.black.withValues(alpha: 0.4),
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
