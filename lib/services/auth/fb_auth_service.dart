import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:new_application_api/models/login_response.dart';
import 'package:new_application_api/config.dart';

class FbAuthService {
  Future<LoginResponse> signInWithFb() async {
    final String baseUrl = AppConfig.baseUrl;

    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;

      final response = await http.post(
        Uri.parse('$baseUrl/facebook/callback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': accessToken.tokenString}),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Error al iniciar sesión con Facebook');
      }
    } else {
      throw Exception(
          'Error al iniciar sesión con Facebook: ${result.message}');
    }
  }
}
