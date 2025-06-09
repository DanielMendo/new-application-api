import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:app_links/app_links.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'firebase_options.dart';
import 'package:new_application_api/controllers/notification_controller.dart';
import 'package:new_application_api/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Notificaciones Básicas',
        channelDescription: 'Canal para notificaciones básicas',
        defaultColor: Color.fromARGB(255, 19, 75, 173),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        icon: 'resource://drawable/res_app_icon',
      ),
    ],
  );

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  await AwesomeNotificationsFcm().initialize(
    onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
    onFcmTokenHandle: NotificationController.myFcmTokenHandle,
    onNativeTokenHandle: NotificationController.myNativeTokenHandle,
    debug: true,
  );

  timeago.setLocaleMessages('es', timeago.EsMessages());
  await AwesomeNotificationsFcm().requestFirebaseAppToken();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && mounted) {
        _handleDeepLink(uri);
      }
    });

    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error initializing deep link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep link recibido: $uri');
    if (uri.host == 'bloogol.com' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'post') {
      String postId = uri.pathSegments[1];
      router.go('/post/$postId');
    } else {
      router.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bloogol',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
        primaryColor: const Color.fromARGB(255, 19, 75, 173),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 19, 75, 173),
          secondary: Colors.blueAccent,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.latoTextTheme(),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 19, 75, 173),
          secondary: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
