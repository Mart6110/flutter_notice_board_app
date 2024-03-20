import 'dart:convert';
import 'package:flutter/material.dart';

// NoticeBoardItem widget displays an image on the notice board with drag and drop functionality
class NoticeBoardItem extends StatelessWidget {
  final String base64Image; // Base64 encoded image data
  final void Function(String) onDrop; // Callback function when the item is dropped

  const NoticeBoardItem({
    super.key,
    required this.base64Image,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: DragTarget<String>(
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () => onDrop(base64Image), // Call onDrop function when tapped
            child: _decodeAndDisplayImage(base64Image), // Display the image
          );
        },
        onWillAcceptWithDetails: (data) => true, // Allow drop operation
        onAcceptWithDetails: (data) => onDrop(base64Image), // Call onDrop function when accepted
      ),
    );
  }

  // Helper function to decode and display the image
  Widget _decodeAndDisplayImage(String base64Image) {
    try {
      return Image.memory(
        base64Decode(base64Image),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    } catch (e) {
      print('Error decoding image: $e');
      return Container(); // or display an error placeholder
    }
  }
}
