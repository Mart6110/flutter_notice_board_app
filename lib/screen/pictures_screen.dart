import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notice_board_app/states/pictures_state.dart';

class PicturesScreen extends StatefulWidget {
  final List<String> base64ImageList;

  const PicturesScreen({Key? key, required this.base64ImageList})
      : super(key: key);

  @override
  _PicturesScreenState createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  final PicturesState _state = PicturesState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictures'),
        actions: [
          _state.token != null
              ? IconButton(
                  onPressed: () => _state.logout(),
                  icon: const Icon(Icons.logout),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                final token = await _state.login();
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to login: $e')),
                );
              }
            },
            child: _state.token != null
                ? const Text('Logout')
                : const Text('Login'),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: widget.base64ImageList.length,
              itemBuilder: (context, index) {
                final base64Image = widget.base64ImageList[index];
                return GestureDetector(
                  onTap: () => _uploadImage(index),
                  child: Image.memory(
                    base64Decode(base64Image),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage(int index) async {
    if (_state.token != null) {
      try {
        await _state.uploadBase64Image(widget.base64ImageList[index], _state.token!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }
}
