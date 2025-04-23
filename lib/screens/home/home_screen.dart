import 'package:flutter/material.dart';
import 'package:new_application_api/screens/auth/login_screen.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/services/auth/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final user = UserSession.currentUser;

  void _logout() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await AuthService().logout(UserSession.token!);

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (response.success) {
        UserSession.clearSession();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        SnackBar(
          content: Text(response.message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      SnackBar(
        content: Text("Error logging out"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // toolbarHeight: 80,
          title: Text(
            'Bloogol',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            // TextButton.icon(
            //   onPressed: () => _logout(),
            //   icon: Icon(Iconsax.logout, color: Colors.black, size: 20),
            //   label: Text(
            //     "Logout",
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontSize: 14,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // )
            IconButton(
              onPressed: () => _logout(),
              icon: Icon(Iconsax.notification, color: Colors.black, size: 20),
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(24),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// --- [User Info] --- ///
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "User information",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Name: ${user?.name}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Last name: ${user?.lastName}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
