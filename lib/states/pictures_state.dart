import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// PicturesState class manages the state and actions related to pictures.
class PicturesState {
  String? token; // Token for authentication

  // Method to log in and obtain authentication token.
  Future<String> login() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/login'), // API endpoint for login
      headers: {'Content-Type': 'application/json'}, // Request headers
      body: jsonEncode({'username': 'mmtest', 'password': '1234'}), // Request body (username and password)
    );

    // Check if login was successful (status code 200)
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Decode response body
      token = data['token']; // Extract token from response data
      return token!; // Return the obtained token
    } else {
      throw Exception('Failed to login'); // Throw an exception if login fails
    }
  }

  // Method to logout by clearing the token.
  Future<void> logout() async {
    token = null; // Clear the token
  }

  // Method to upload a base64 encoded image with authentication token.
  Future<void> uploadBase64Image(String base64Image, String token) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/add_image'), // API endpoint for uploading image
      headers: {'Content-Type': 'application/json', 'Authorization': token}, // Request headers (including token)
      body: jsonEncode({'imgbase64': base64Image}), // Request body (base64 encoded image)
    );

    // Check if image upload was successful (status code 200)
    if (response.statusCode != 200) {
      throw Exception('Failed to upload image'); // Throw an exception if upload fails
    }
  }
}
