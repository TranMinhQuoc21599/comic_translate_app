import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../translation/presentation/pages/translation_screen.dart';

class LinkUploadScreen extends StatefulWidget {
  const LinkUploadScreen({super.key});

  @override
  State<LinkUploadScreen> createState() => _LinkUploadScreenState();
}

class _LinkUploadScreenState extends State<LinkUploadScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  final List<String> _downloadedImages = [];
  final Set<int> _selectedImages = {};
  String _downloadProgress = '';

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _clearImages() {
    setState(() {
      _downloadedImages.clear();
      _selectedImages.clear();
    });
  }

  Future<List<String>> _getMangaDexImageUrls(String url) async {
    try {
      // Extract chapter ID from URL
      final RegExp regExp = RegExp(r'chapter/([^/]+)');
      final match = regExp.firstMatch(url);
      if (match == null) {
        throw Exception(
            'Invalid MangaDex chapter URL. Expected format: https://mangadex.org/chapter/[chapter-id]');
      }
      final chapterId = match.group(1);

      // Get chapter data from MangaDex API
      final response = await http.get(
        Uri.parse('https://api.mangadex.org/at-home/server/$chapterId'),
        headers: {
          'User-Agent': 'ComicTranslateApp/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 404) {
        throw Exception('Chapter not found on MangaDex');
      } else if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch chapter data from MangaDex (Status: ${response.statusCode})');
      }

      final data = json.decode(response.body);
      if (data == null || data['baseUrl'] == null || data['chapter'] == null) {
        throw Exception('Invalid response from Ma ngaDex API');
      }

      final String baseUrl = data['baseUrl'] as String;
      final Map<String, dynamic> chapter =
          data['chapter'] as Map<String, dynamic>;
      final String hash = chapter['hash'] as String;
      final List<dynamic> images = chapter['data'] as List<dynamic>;

      if ((images.isEmpty)) {
        throw Exception('No images found in this chapter');
      }

      // Get all image URLs from the chapter
      return List<String>.from(
        (images).map((filename) => '$baseUrl/data/$hash/$filename'),
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to process MangaDex URL: ${e.toString()}');
    }
  }

  bool _isValidImageUrl(String url) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAbsolutePath) return false;
    return imageExtensions.any((ext) => uri.path.toLowerCase().endsWith(ext));
  }

  Future<void> _downloadAndProcessImage(String url) async {
    try {
      // Clear existing images when starting a new download
      _clearImages();

      setState(() {
        _isLoading = true;
        _downloadProgress = 'Preparing download...';
      });

      // Normalize URL
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }

      List<String> imageUrls = [];
      if (url.contains('mangadex.org')) {
        if (!url.contains('/chapter/')) {
          throw Exception('Please provide a direct MangaDex chapter URL');
        }
        setState(() => _downloadProgress = 'Fetching chapter data...');
        imageUrls = await _getMangaDexImageUrls(url);
      } else {
        // Validate single image URL
        if (!_isValidImageUrl(url)) {
          throw Exception(
              'Invalid image URL. Supported formats: JPG, JPEG, PNG, GIF, WEBP');
        }
        imageUrls = [url];
      }

      // Download all images
      for (int i = 0; i < imageUrls.length; i++) {
        if (!mounted) return;
        setState(() => _downloadProgress =
            'Downloading image ${i + 1}/${imageUrls.length}');

        final imageUrl = imageUrls[i];
        final response = await http.get(
          Uri.parse(imageUrl),
          headers: {
            'User-Agent': 'ComicTranslateApp/1.0',
            'Accept': 'image/*',
          },
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Failed to download image ${i + 1} (Status: ${response.statusCode})');
        }

        // Check if it's an image
        final contentType = response.headers['content-type'];
        if (contentType == null || !contentType.startsWith('image/')) {
          throw Exception(
              'Invalid content type for image ${i + 1}: $contentType');
        }

        // Save the image
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'comic_${DateTime.now().millisecondsSinceEpoch}_$i${path.extension(imageUrl)}';
        final file = File(path.join(tempDir.path, fileName));
        await file.writeAsBytes(response.bodyBytes);

        if (!mounted) return;
        setState(() {
          _downloadedImages.add(file.path);
          if (_downloadedImages.length == 1) {
            _selectedImages.add(0); // Select first image by default
          }
        });
      }

      _urlController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully downloaded ${imageUrls.length} image(s)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _downloadProgress = '';
        });
      }
    }
  }

  void _proceedToTranslation() {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    // Get all selected images in order
    final selectedImages = _selectedImages.toList()..sort();
    final imagePaths =
        selectedImages.map((index) => _downloadedImages[index]).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranslationScreen(
          imagePaths: imagePaths,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload from Link'),
        actions: [
          if (_downloadedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearImages,
              tooltip: 'Clear all images',
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Comic URL',
                    hintText:
                        'Paste a direct image link or MangaDex chapter URL',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          final url = _urlController.text.trim();
                          if (url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter a URL')),
                            );
                            return;
                          }
                          _downloadAndProcessImage(url);
                        },
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(_downloadProgress),
                          ],
                        )
                      : const Text('Add Image'),
                ),
              ],
            ),
          ),
          if (_downloadedImages.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_downloadedImages.length} images',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed:
                        _selectedImages.isEmpty ? null : _proceedToTranslation,
                    icon: const Icon(Icons.translate),
                    label: const Text('Translate Selected'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: _downloadedImages.isEmpty
                ? const Center(
                    child: Text(
                      'No images added yet\nPaste a URL above to add images',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _downloadedImages.length,
                    itemBuilder: (context, index) {
                      final imagePath = _downloadedImages[index];
                      final isSelected = _selectedImages.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedImages.remove(index);
                            } else {
                              _selectedImages
                                  .add(index); // Allow multiple selection
                            }
                          });
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Card(
                              elevation: isSelected ? 8 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isSelected
                                    ? const BorderSide(
                                        color: Colors.blue, width: 2)
                                    : BorderSide.none,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Colors.blue : Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
