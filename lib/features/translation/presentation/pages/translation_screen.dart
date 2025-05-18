import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/scan_animation_widget.dart';
import 'translation_complete_screen.dart';
import '../../../../shared/services/aistudio_service.dart';

class TranslationScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const TranslationScreen({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  late PageController _pageController;
  late int _currentPage;
  bool _isScanning = false;
  final AiStudioService _aiStudioService = AiStudioService();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Translate Comic (${_currentPage + 1}/${widget.imagePaths.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _currentPage < widget.imagePaths.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.imagePaths.length,
              itemBuilder: (context, index) {
                final imageWidget = InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(widget.imagePaths[index]),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                );
                return _isScanning && index == _currentPage
                    ? ScanAnimationWidget(
                        onScanComplete: () {},
                        regions: const [],
                        child: imageWidget, // Add required regions parameter
                      )
                    : imageWidget;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isScanning = true;
                      });

                      final imageFile = File(widget.imagePaths[_currentPage]);
                      final regions = await _aiStudioService
                          .extractTextRegionsFromImage(imageFile);
                      final translatedText =
                          regions.map((r) => r.text).join('\n');

                      if (!mounted) return;

                      setState(() {
                        _isScanning = false;
                      });

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  TranslationBatchCompleteScreen(
                            results: [
                              TranslationResult(
                                  imagePath: widget.imagePaths[_currentPage],
                                  translatedText: translatedText ??
                                      'No text found or translation failed.')
                            ],
                            onDone: () => Navigator.of(context).pop(),
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: const Text('Translate'),
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

class TextRegion {
  final Rect boundingBox;
  final String text;
  final String? translatedText;
  TextRegion(
      {required this.boundingBox, required this.text, this.translatedText});
}
