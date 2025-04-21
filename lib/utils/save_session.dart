import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_application_api/models/user.dart';


class SaveSession {
  static Future<void> saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    
  }

  static Future<void> removeSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }
}