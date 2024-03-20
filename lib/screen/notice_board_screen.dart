import 'dart:convert';

import 'package:flutter/material.dart';

class NoticeBoardScreen extends StatefulWidget {
  final List<String> base64ImageList;

  const NoticeBoardScreen({Key? key, required this.base64ImageList})
      : super(key: key);

  @override
  _NoticeBoardScreenState createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Board'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DragTarget<int>(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: widget.base64ImageList.isNotEmpty
                        ? Stack(
                            children: List.generate(
                              widget.base64ImageList.length,
                              (index) => _NoticeItem(
                                index: index,
                                base64ImageList: widget.base64ImageList,
                              ),
                            ),
                          )
                        : Text(
                            'Drop images here',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                  ),
                );
              },
              onAccept: (int data) {
                setState(() {
                  if (data != null) {
                    widget.base64ImageList.add(data.toString());
                  }
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
                  return Draggable<int>(
                    data: widget.base64ImageList.indexOf(base64Image),
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

class _NoticeItem extends StatelessWidget {
  final int index;
  final List<String> base64ImageList;

  const _NoticeItem(
      {Key? key, required this.index, required this.base64ImageList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: Draggable<int>(
        data: index,
        feedback: _decodeAndDisplayImage(base64ImageList[index]),
        childWhenDragging: Container(),
        child: _decodeAndDisplayImage(base64ImageList[index]),
      ),
    );
  }

  Widget _decodeAndDisplayImage(String base64Image) {
    try {
      return Image.memory(
        base64Decode(base64Image),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } catch (e) {
      print('Error decoding image: $e');
      return Container(); // or display an error placeholder
    }
  }
}
