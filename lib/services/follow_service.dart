import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/config.dart';

class FollowService {
  final String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> fetchFollowStats(
      int userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/follow-stats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Error al obtener estadísticas');
    }
  }

  Future<List<User>> getFollowers(int userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/followers'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((user) => User.fromJson(user))
          .toList();
    } else {
      throw Exception('Error al obtener seguidores');
    }
  }

  Future<List<User>> getFollowing(int userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/following'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((user) => User.fromJson(user))
          .toList();
    } else {
      throw Exception('Error al obtener siguiendo');
    }
  }
}
