import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PicturesScreen extends StatefulWidget {
  final List<String> base64ImageList;

  const PicturesScreen({Key? key, required this.base64ImageList})
      : super(key: key);

  @override
  _PicturesScreenState createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  String? _token;

  Future<String> _login() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': 'mmtest', 'password': '1234'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> _logout() async {
    setState(() {
      _token = null;
    });
  }

  Future<void> _selectAndUploadImage(int index) async {
    if (index < 0 || index >= widget.base64ImageList.length) return;

    final base64Image = widget.base64ImageList[index];
    try {
      await _uploadBase64Image(base64Image, _token!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _uploadBase64Image(String base64Image, String token) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/add_image'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'imgbase64': base64Image}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictures'),
        actions: [
          _token != null
              ? IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                final token = await _login();
                setState(() {
                  _token = token;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to login: $e')),
                );
              }
            },
            child: _token != null
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
                  onTap: () => _selectAndUploadImage(index),
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
}
