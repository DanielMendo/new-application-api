import 'package:new_application_api/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:new_application_api/screens/home/home_screen.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
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
          textTheme: GoogleFonts.latoTextTheme(),
          primaryColor: const Color.fromARGB(255, 19, 75, 173),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Color.fromARGB(255, 19, 75, 173),
            secondary: Colors.blueAccent,
          ),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          quill.FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
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
