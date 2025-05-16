import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/login_response.dart';
import '../../models/api_response.dart';

class AuthService {
  final String baseUrl = 'https://bloogol.com/api';

  // Login
  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}));

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Something went wrong');
    }
  }

  // Register
  Future<LoginResponse> register(String name, String lastName, String phone,
      String email, String password) async {
    final response = await http.post(Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'name': name,
          'last_name': lastName,
          'phone': phone,
          'email': email,
          'password': password
        }));

    if (response.statusCode == 201) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Something went wrong');
    }
  }

  // Logout
  Future<ApiResponse> logout(String token) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/logout'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      });

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        return ApiResponse(success: false, message: data['message']);
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Send Forgot Password
  Future<ApiResponse> sendForgotPassword(String email) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/forgot-password'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'email': email}));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        return ApiResponse(success: false, message: data['message']);
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Update Email
  Future<ApiResponse> updateEmail(String newEmail, String token) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/users/email'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({'email': newEmail}));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        return ApiResponse(success: false, message: data['message']);
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Update Password
  Future<ApiResponse> updatePassword(
      String currentPassword, String newPassword, String token) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/users/password'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'current_password': currentPassword,
            'new_password': newPassword
          }));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        return ApiResponse(success: false, message: data['message']);
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  // Delete Account
  Future<ApiResponse> deleteAccount(String password, String token) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/delete'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({'password': password}));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        return ApiResponse(success: false, message: data['message']);
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}
