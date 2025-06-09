import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_application_api/models/comment.dart';
import 'package:new_application_api/config.dart';

class CommentService {
  final String baseUrl = '${AppConfig.baseUrl}/posts';

  Future<List<Comment>> fetchComments(
      int postId, String token, String order) async {
    final uri = Uri.parse('$baseUrl/$postId/comments').replace(
      queryParameters: {'order': order},
    );

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar comentarios');
    }
  }

  Future<void> sendComment(
      {required int postId,
      required String content,
      int? parentId,
      required String token}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$postId/comment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al enviar comentario');
    }
  }

  Future<void> deleteComment(int commentId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$commentId/comment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar comentario');
    }
  }

  Future<void> toggleLike(int commentId, String token, bool isLiked) async {
    if (isLiked) {
      final response = await http.delete(
        Uri.parse('$baseUrl/comments/$commentId/like'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar like');
      }
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl/comments/$commentId/like'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al dar like');
      }
    }
  }
}
