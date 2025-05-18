import 'package:flutter/material.dart';
import '../widgets/scan_animation_widget.dart';

import 'translation_complete_screen.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({Key? key}) : super(key: key);

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  bool _isScanning = false;
  String? _selectedImagePath;
  String? _translatedText;

  void _startTranslation() {
    if (_selectedImagePath == null) return;

    setState(() {
      _isScanning = true;
    });

    // Simulate translation process
    Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        _isScanning = false;
        _translatedText =
            "This is a sample translated text. Replace this with actual translation results.";
      });

      // Show completion screen with fade transition
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TranslationBatchCompleteScreen(
            results: [
              TranslationResult(
                  imagePath: _selectedImagePath!,
                  translatedText:
                      _translatedText ?? 'No text found or translation failed.')
            ],
            // imagePath: _selectedImagePath!,
            onDone: () => Navigator.of(context).pop(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking
    setState(() {
      _selectedImagePath = "dummy_path";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comic Translation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedImagePath == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_search,
                          size: 64,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select an image to translate',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  )
                : _isScanning
                    ? ScanAnimationWidget(
                        regions: [], // Add required regions parameter
                        child: Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text('Scanning and Translating...'),
                          ),
                        ),
                        onScanComplete: () {},
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text('Selected Image Preview'),
                        ),
                      ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Select Image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedImagePath != null && !_isScanning
                        ? _startTranslation
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.translate, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Translate',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
