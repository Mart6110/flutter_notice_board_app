import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class PicturesState {
  String? token;

  Future<String> login() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': 'mmtest', 'password': '1234'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['token'];
      return token!;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> logout() async {
    token = null;
  }

  Future<void> uploadBase64Image(String base64Image, String token) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/add_image'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'imgbase64': base64Image}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload image');
    }
  }
}
