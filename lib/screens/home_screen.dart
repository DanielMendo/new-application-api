import 'package:flutter/material.dart';
import 'package:new_application_api/screens/login_screen.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  final user = UserSession.currentUser;

  void _logout() async {
    try {
      final response = await http
          .post(Uri.parse('http://localhost:8000/api/logout'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${UserSession.token}'
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        UserSession.clearSession();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
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
          backgroundColor: Theme.of(context).primaryColor,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          title: Text('Home',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () => _logout(),
              icon: Icon(Iconsax.logout, color: Colors.white, size: 20),
              label: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
