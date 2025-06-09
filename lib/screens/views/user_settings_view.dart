import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/services/auth/auth_service.dart';
import 'package:new_application_api/services/notification_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({super.key});

  @override
  _UserSettingsViewState createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = UserSession.currentUser!;
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await _deleteFcmToken(UserSession.token!);

    final response = await AuthService().logout(UserSession.token!);

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    if (response.success) {
      UserSession.clearSession();
      if (context.mounted) {
        context.go('/login');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFcmToken(String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = prefs.getString('fcm_token');

    if (fcmToken != null) {
      await NotificationService().deleteDeviceToken(authToken, fcmToken);
      prefs.remove('fcm_token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 16),
          Text(
            '${user.name} ${user.lastName ?? ''}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Divider(height: 32),

          // Sección de Cuenta
          const Text(
            'Configuración de la cuenta',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(PhosphorIcons.envelopeSimpleOpenLight),
            title: const Text('Cambiar email'),
            onTap: () async {
              final updatedUser = await context.push<User>('/change-email');

              if (updatedUser != null) {
                setState(() {
                  user = updatedUser;
                  UserSession.currentUser = updatedUser;
                });
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(PhosphorIcons.lock),
            title: const Text('Cambiar contraseña'),
            onTap: () {
              context.push('/change-password');
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(PhosphorIcons.trashSimple),
            title: const Text('Eliminar cuenta'),
            onTap: () {
              context.push('/delete-account');
            },
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Sección de Logout
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(PhosphorIcons.signOut, color: Colors.red),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
