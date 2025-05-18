import 'package:flutter/material.dart';
// import '../translation/translation_screen.dart';

class LinkUploadScreen extends StatefulWidget {
  const LinkUploadScreen({super.key});

  @override
  State<LinkUploadScreen> createState() => _LinkUploadScreenState();
}

class _LinkUploadScreenState extends State<LinkUploadScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload from Link')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Comic URL',
                hintText: 'Paste a direct image link or comic site URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final url = _urlController.text.trim();
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a URL')),
                  );
                  return;
                }
                // TODO: Implement URL validation and processing
              },
              child: const Text('Translate'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Supported sites:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Direct image links (JPG, PNG, WEBP)'),
            const Text('• Webtoon'),
            const Text('• MangaDex'),
          ],
        ),
      ),
    );
  }
}
