import 'dart:convert';
import 'package:new_application_api/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static User? currentUser;
  static String? token;

  static Future<void> setSession(User user, String token,
      {bool rememberMe = false}) async {
    UserSession.currentUser = user;
    UserSession.token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setString('token', token);
    await prefs.setBool('rememberMe', rememberMe);
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (!rememberMe) {
      await clearSession();
    }

    final userJson = prefs.getString('user');
    final tokenString = prefs.getString('token');

    if (userJson != null && tokenString != null) {
      currentUser = User.fromJson(jsonDecode(userJson));
      token = tokenString;
    }
  }

  static Future<void> clearSession() async {
    currentUser = null;
    token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
  }

  static bool isLoggedIn() {
    return token != null;
  }
}
