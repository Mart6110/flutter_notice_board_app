import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notice_board_app/components/notice_board_item.dart';
import 'package:flutter_notice_board_app/states/notice_board_state.dart';

// NoticeBoardScreen widget displays the notice board with draggable images
class NoticeBoardScreen extends StatefulWidget {
  final List<String> base64ImageList; // List of base64 encoded image data

  const NoticeBoardScreen({Key? key, required this.base64ImageList})
      : super(key: key);

  @override
  _NoticeBoardScreenState createState() => _NoticeBoardScreenState();
}

// _NoticeBoardScreenState class manages the state of the NoticeBoardScreen widget
class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  late final NoticeBoardState _state; // State for managing the notice board

  @override
  void initState() {
    super.initState();
    _state = NoticeBoardState(base64ImageList: []); // Initialize the state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Board'), // App bar title
      ),
      body: Column(
        children: [
          Expanded(
            child: DragTarget<String>(
              builder: (context, candidateData, rejectedData) {
                return GridView.count(
                  crossAxisCount: 3,
                  children: _state.base64ImageList.map((base64Image) {
                    return NoticeBoardItem(
                      base64Image: base64Image,
                      onDrop: (base64Image) {
                        setState(() {
                          _state.removeImage(base64Image);
                        });
                      },
                    );
                  }).toList(),
                );
              },
              onAcceptWithDetails: (DragTargetDetails<String> details) {
                setState(() {
                  _state.addImages([details.data]); // Add dropped images
                });
              },
            ),
          ),
          Container(
            height: 120,
            child: GridView.count(
              crossAxisCount: 5,
              childAspectRatio: 1,
              children: widget.base64ImageList.map<Widget>(
                (base64Image) {
                  return Draggable<String>(
                    data: base64Image,
                    feedback: _decodeAndDisplayImage(base64Image),
                    childWhenDragging: Container(),
                    child: _decodeAndDisplayImage(base64Image),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Decodes and displays the image from base64 encoded data
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
