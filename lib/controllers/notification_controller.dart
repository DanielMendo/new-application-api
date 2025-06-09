import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    final data = silentData.data;

    final layout = data?['layout'] ?? 'Default';
    final notificationLayout = _getLayout(layout);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: data?['channelKey'] ?? 'basic_channel',
        title: data?['title'],
        body: data?['body'],
        notificationLayout: notificationLayout,
        bigPicture: layout == 'BigPicture' ? data!['image'] : null,
        largeIcon: layout == 'Default' ? data!['image'] : null,
        payload: data,
      ),
    );
  }

  static Future<void> myFcmTokenHandle(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print('📥 Token FCM guardado en SharedPreferences: $token');
    // final String baseUrl = AppConfig.baseUrl;
    // final authToken = UserSession.token;
    // if (authToken != null) {
    //   final response = await http.put(
    //     Uri.parse('$baseUrl/update-device-token'),
    //     headers: {
    //       'Authorization': 'Bearer $authToken',
    //       'Content-Type': 'application/json',
    //     },
    //     body: jsonEncode({'fcm_token': token}),
    //   );
    //   print('Respuesta de actualización de token: ${response.body}');
    // }
  }

  static Future<void> myNativeTokenHandle(String token) async {
    // Manejar token nativo si es necesario
    print('Token nativo recibido: $token');
  }
}

NotificationLayout _getLayout(String layout) {
  switch (layout) {
    case 'BigPicture':
      return NotificationLayout.BigPicture;
    case 'Default':
    default:
      return NotificationLayout.Default;
  }
}
