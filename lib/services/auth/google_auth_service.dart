import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../models/login_response.dart';
import 'package:new_application_api/config.dart';
import 'dart:convert';

class GoogleAuthService {
  final String baseUrl = AppConfig.baseUrl;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<LoginResponse> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("Inicio de sesión cancelado");
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.accessToken;

    final response = await http.post(
      Uri.parse('$baseUrl/google/callback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Error al iniciar sesión con Google');
    }
  }
}
