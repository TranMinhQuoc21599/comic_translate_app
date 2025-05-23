import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/scan_animation_widget.dart';
import 'translation_complete_screen.dart';
import '../../../../shared/services/aistudio_service.dart' as ai;

/// A screen that handles the translation of comic images.
/// Allows users to navigate through multiple images and translate them.
///
/// Màn hình xử lý việc dịch truyện tranh.
/// Cho phép người dùng điều hướng qua nhiều hình ảnh và dịch chúng.
class TranslationScreen extends StatefulWidget {
  /// List of image paths to be translated
  /// Danh sách đường dẫn hình ảnh cần dịch
  final List<String> imagePaths;

  /// Initial index to start with in the image list
  /// Vị trí bắt đầu trong danh sách hình ảnh
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
  /// Controller for handling page transitions between images
  /// Bộ điều khiển xử lý chuyển trang giữa các hình ảnh
  late PageController _pageController;

  /// Current page index being displayed
  /// Vị trí trang hiện tại đang hiển thị
  late int _currentPage;

  /// Flag indicating if translation is in progress
  /// Cờ báo hiệu quá trình dịch đang diễn ra
  bool _isScanning = false;

  /// Progress value for the translation process (0.0 to 1.0)
  /// Giá trị tiến trình của quá trình dịch (từ 0.0 đến 1.0)
  double _translationProgress = 0.0;

  /// Service for handling AI-related operations
  /// Dịch vụ xử lý các thao tác liên quan đến AI
  final ai.AiStudioService _aiStudioService = ai.AiStudioService();

  /// Map storing translation results for each image index
  /// Bản đồ lưu trữ kết quả dịch cho từng vị trí hình ảnh
  final Map<int, List<ai.TextRegion>> _translatedRegions = {};

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

  /// Resets all translation results and states
  /// Clears the translated regions map and resets progress indicators
  ///
  /// Đặt lại tất cả kết quả và trạng thái dịch
  /// Xóa bản đồ vùng đã dịch và đặt lại các chỉ số tiến trình
  void _resetTranslationResults() {
    setState(() {
      _translatedRegions.clear();
      _isScanning = false;
      _translationProgress = 0.0;
    });
  }

  /// Starts the translation process for the current image
  /// Handles the entire flow from text extraction to translation
  ///
  /// Bắt đầu quá trình dịch cho hình ảnh hiện tại
  /// Xử lý toàn bộ quy trình từ trích xuất văn bản đến dịch
  Future<void> _startTranslation() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _translationProgress = 0.0;
    });

    Timer? progressTimer;
    try {
      // Simulate progress updates for better UX
      // Giả lập cập nhật tiến trình để cải thiện trải nghiệm người dùng
      progressTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_translationProgress < 0.9) {
          setState(() {
            _translationProgress += 0.1;
          });
        }
      });

      // Extract text regions from the current image
      // Trích xuất vùng văn bản từ hình ảnh hiện tại
      final imageFile = File(widget.imagePaths[_currentPage]);
      final regions =
          await _aiStudioService.extractTextRegionsFromImage(imageFile);

      if (!mounted) return;

      // Translate the extracted text regions to Vietnamese
      // Dịch các vùng văn bản đã trích xuất sang tiếng Việt
      final translatedRegions =
          await _aiStudioService.translateTextRegionsToVietnamese(regions);

      setState(() {
        _translatedRegions[_currentPage] = translatedRegions;
        _translationProgress = 1.0;
      });

      // Wait for scan animation to complete
      // Đợi hoàn thành hiệu ứng quét
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Format the translation results for display
      // Định dạng kết quả dịch để hiển thị
      final formattedText = translatedRegions
          .map(
              (r) => '${r.text}\n→ ${r.translatedText ?? "Translation failed"}')
          .join('\n\n');

      // Navigate to the results screen
      // Chuyển đến màn hình kết quả
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TranslationBatchCompleteScreen(
            results: [
              TranslationResult(
                imagePath: widget.imagePaths[_currentPage],
                translatedText: formattedText,
              )
            ],
            onDone: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanning = false;
                _translationProgress = 0.0;
              });
            },
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
    } catch (e) {
      if (!mounted) return;
      // Show error message and reset state
      // Hiển thị thông báo lỗi và đặt lại trạng thái
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during translation: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      _resetTranslationResults();
    } finally {
      progressTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Translate Comic (${_currentPage + 1}/${widget.imagePaths.length})'),
        actions: [
          // Reset button to clear all translations
          // Nút đặt lại để xóa tất cả bản dịch
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _resetTranslationResults,
            tooltip: 'Reset translations',
          ),
          // Navigation buttons for previous/next images
          // Nút điều hướng cho hình ảnh trước/sau
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _currentPage > 0 && !_isScanning
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
            onPressed:
                _currentPage < widget.imagePaths.length - 1 && !_isScanning
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
      body: Stack(
        children: [
          Column(
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
                    // Build image viewer with zoom capabilities
                    // Xây dựng trình xem hình ảnh với khả năng phóng to
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
                    // Show scan animation when translating current image
                    // Hiển thị hiệu ứng quét khi đang dịch hình ảnh hiện tại
                    return _isScanning && index == _currentPage
                        ? ScanAnimationWidget(
                            onScanComplete: () {},
                            regions: _translatedRegions[_currentPage]
                                    ?.map((r) => r.boundingBox)
                                    .toList() ??
                                [],
                            child: imageWidget,
                          )
                        : imageWidget;
                  },
                ),
              ),
              // Translation button
              // Nút dịch
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : _startTranslation,
                        child:
                            Text(_isScanning ? 'Translating...' : 'Translate'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Loading overlay with progress indicator
          // Lớp phủ tải với chỉ báo tiến trình
          if (_isScanning)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _translationProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(_translationProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Translating...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ImageChooseScreen extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTranslate;

  const ImageChooseScreen({
    Key? key,
    required this.imagePath,
    required this.onTranslate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ảnh'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: const Icon(Icons.rotate_left), onPressed: () {/* TODO */}),
          IconButton(
              icon: const Icon(Icons.rotate_right), onPressed: () {/* TODO */}),
          IconButton(icon: const Icon(Icons.crop), onPressed: () {/* TODO */}),
        ],
      ),
      body: Center(
        child: Image.file(File(imagePath), fit: BoxFit.contain),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 48),
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.translate),
          label: const Text('Dịch', style: TextStyle(fontSize: 18)),
          onPressed: onTranslate,
        ),
      ),
    );
  }
}
