import 'package:flutter/material.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/screens//home/home_screen.dart';
import 'package:new_application_api/services/auth/google_auth_service.dart';
import 'package:new_application_api/services/auth/fb_auth_service.dart';

class AuthHelpers {
  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final loginResponse = await GoogleAuthService().signInWithGoogle();

      if (!context.mounted) return;

      if (loginResponse.token != null) {
        UserSession.setSession(loginResponse.user!, loginResponse.token!);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> signInWithFb(BuildContext context) async {
    try {
      final loginResponse = await FbAuthService().signInWithFb();

      if (!context.mounted) return;

      if (loginResponse.token != null) {
        UserSession.setSession(loginResponse.user!, loginResponse.token!);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
