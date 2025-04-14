import 'package:new_application_api/models/user.dart';

class UserSession {
  static User? currentUser;
  static String? token;

  static void setSession(User user, String token) {
    UserSession.token = token;
    UserSession.currentUser = user;
  }

  static void clearSession() {
    UserSession.token = null;
    UserSession.currentUser = null;
  }

  static bool isLoggedIn() {
    return UserSession.token != null;
  }

  
}