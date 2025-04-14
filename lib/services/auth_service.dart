import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_response.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8000/api';

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}));
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Error de autenticación');
    }
  }

  Future<LoginResponse> register(String name, String lastName, String phone, String email,
      String password) async {
    final response = await http.post(Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(
            {'name': name, 'last_name': lastName, 'phone': phone, 'email': email, 'password': password}));
    if (response.statusCode == 201) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Verifica los datos');
    }
  }

  Future<LoginResponse> logout(String token) async {
    final response = await http.post(Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        });
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cerrar sesión');
    }
  }
  
}