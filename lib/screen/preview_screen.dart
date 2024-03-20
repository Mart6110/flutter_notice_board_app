import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// PreviewScreen widget displays a preview of the captured image
class PreviewScreen extends StatefulWidget {
  final String? base64Image; // Base64 encoded image data

  const PreviewScreen({super.key, this.base64Image});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

// _PreviewScreenState class manages the state of the PreviewScreen widget
class _PreviewScreenState extends State<PreviewScreen> {
  late ImageProvider imageProvider; // Image provider to display the image

  @override
  void initState() {
    super.initState();
    if (widget.base64Image != null) {
      // Decode the base64 encoded image data
      final Uint8List decodedBytes = base64Decode(widget.base64Image!);
      // Create a memory image from the decoded bytes
      imageProvider = MemoryImage(decodedBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.base64Image != null
            ? Image(image: imageProvider, fit: BoxFit.cover) // Display the image
            : Container(), // If no image data is provided, display an empty container
      ),
    );
  }
}
