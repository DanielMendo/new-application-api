import 'package:http/http.dart' as http;
import 'package:new_application_api/config.dart';
import 'dart:convert';

import 'package:new_application_api/models/notification.dart';

class NotificationService {
  final String baseUrl = AppConfig.baseUrl;

  Future<void> uploadDeviceToken(String token, String fcmToken) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update-device-token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar token');
    }
  }

  Future<void> deleteDeviceToken(String token, String fcmToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete-device-token'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar token');
    }
  }

  Future<List<Notify>> fetchNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      // Convierte cada item en Notification usando el factory fromJson
      return data.map((json) => Notify.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener notificaciones');
    }
  }

  Future<int> getUnreadCount(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['count'] ?? 0;
    } else {
      throw Exception('Error al obtener cantidad de no leídas');
    }
  }

  Future<void> markAllAsRead(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/mark-read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al marcar como leídas');
    }
  }
}
