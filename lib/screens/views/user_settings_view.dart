import 'package:flutter/material.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/views/settings/change_email.dart';
import 'package:new_application_api/screens/views/settings/change_password.dart';
import 'package:new_application_api/screens/views/settings/delete_account.dart';
import 'package:new_application_api/services/auth/auth_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/screens/auth/login_screen.dart';

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

    final response = await AuthService().logout(UserSession.token!);

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    if (response.success) {
      UserSession.clearSession();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 16),
          Text(
            user.name,
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
            'Account Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: const Text('Change Email'),
            onTap: () async {
              final updatedUser = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeEmailScreen(),
                ),
              );

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
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete Account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteAccountScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Sección de Logout
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Log out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
