import 'dart:io';
import 'package:flutter/material.dart';

class TranslationPage extends StatefulWidget {
  final String imagePath;
  const TranslationPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  bool _isScanning = false;
  bool _scanComplete = false;

  // Dummy data: List of Rects representing detected text bubbles
  final List<Rect> _detectedBubbles = [
    const Rect.fromLTWH(40, 30, 120, 40),
    const Rect.fromLTWH(200, 100, 100, 35),
    const Rect.fromLTWH(80, 200, 140, 50),
  ];

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _scanComplete = false;
    });
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isScanning = false;
      _scanComplete = true;
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
      body: Stack(
        children: [
          // Comic image
          Positioned.fill(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
            ),
          ),
          // Overlay red borders during scan or after scan complete
          if (_isScanning || _scanComplete)
            ..._detectedBubbles.map((rect) => Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: rect.width,
                  height: rect.height,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                  ),
                )),
          // Scan button
          if (!_isScanning && !_scanComplete)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _startScan,
                  child: const Text('Scan Bubbles'),
                ),
              ),
            ),
          // Show result text after scan
          if (_scanComplete)
            const Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Scan complete! Text bubbles highlighted.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
