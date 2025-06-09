import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:new_application_api/models/profile.dart';
import '../models/user.dart';
import 'package:new_application_api/config.dart';

class UserService {
  final String baseUrl = '${AppConfig.baseUrl}/users';

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Ocurrio un error');
    }
  }

  Future<User> getUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ocurrio un error');
    }
  }

  Future<UserProfile> fetchUserProfile(int userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<void> follow(int followerId, String token) async {
    final response =
        await http.post(Uri.parse('$baseUrl/follow/$followerId'), headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to follow user');
    }
  }

  Future<void> unfollow(int followerId, String token) async {
    final response =
        await http.post(Uri.parse('$baseUrl/unfollow/$followerId'), headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to unfollow user');
    }
  }

  Future<String> uploadImage(File imageFile, String token) async {
    final uri = Uri.parse('$baseUrl/image/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'profile_image',
      imageFile.path,
      filename: path.basename(imageFile.path),
    ));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['X-HTTP-Method-Override'] = 'PUT';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['path'];
    } else {
      throw Exception('Error al subir la imagen: ${response.body}');
    }
  }

  Future<void> updateProfile(User user, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${user.id}/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Error al actualizar el usuario: ${response.body}');
    }
  }

  Future<List<User>> searchUsers(String query, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Ocurrio un error');
    }
  }
}
