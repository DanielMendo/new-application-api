import 'package:new_application_api/models/user.dart';

class Notify {
  final int id;
  final String title;
  final String body;
  final String? image;
  final String? type;
  final User? user;
  final DateTime createdAt;
  final DateTime? readAt;

  Notify({
    required this.id,
    required this.title,
    required this.body,
    this.image,
    this.type,
    this.user,
    required this.createdAt,
    this.readAt,
  });

  factory Notify.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return Notify(
      id: data['id'],
      title: data['title'],
      body: data['body'],
      image: data['image'],
      type: data['type'],
      user: data['user'] != null ? User.fromJson(data['user']) : null,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }
}
