import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_application_api/config.dart';

class UnsplashService {
  final String baseUrl = AppConfig.baseUrl;

  Future<List<String>> searchUnsplashImages(String token, String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/unsplash?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results
          .map<String>((item) => item['urls']['regular'] as String)
          .toList();
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}
