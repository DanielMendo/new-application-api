import 'package:new_application_api/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:new_application_api/screens/home/home_screen.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bloogol',
        theme: ThemeData(
          textTheme: GoogleFonts.nunitoTextTheme(),
          primaryColor: const Color.fromARGB(255, 19, 75, 173),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Color.fromARGB(255, 19, 75, 173),
            secondary: Colors.blueAccent,
          ),
        ),
        home: FutureBuilder(
          future: UserSession.loadSession(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (UserSession.isLoggedIn()) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ));
  }
}
