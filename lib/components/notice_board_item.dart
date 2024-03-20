import 'dart:convert';
import 'package:flutter/material.dart';

class NoticeBoardItem extends StatelessWidget {
  final String base64Image;
  final void Function(String) onDrop;

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
            onTap: () => onDrop(base64Image),
            child: _decodeAndDisplayImage(base64Image),
          );
        },
        onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: (data) => onDrop(base64Image),
      ),
    );
  }

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
