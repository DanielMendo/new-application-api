import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_application_api/models/api_response.dart';
import 'package:new_application_api/config.dart';

import '../models/post.dart';

class PostService {
  final String baseUrl = '${AppConfig.baseUrl}/posts';

  Future<List<Post>> getMyPosts(
      int userId, String token, String visibility) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mine/$userId').replace(queryParameters: {
        'visibility': visibility,
      }),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Ocurrio un error');
    }
  }

  Future<List<Post>> getAllPostsExclude(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/exclude/$userId'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Ocurrio un error');
    }
  }

  Future<List<Post>> searchPosts(String query, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<List<Post>> getAllPostsFollowing(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/following'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Ocurrió un error: ${response.statusCode}');
    }
  }

  Future<List<Post>> getAllPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Ocurrio un error');
    }
  }

  Future<List<Post>> getPostsByCategory(int categoryId, String token) async {
    final response = await http.get(Uri.parse('$baseUrl/category/$categoryId'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Ocurrio un error');
    }
  }

  Future<Post> getPost(dynamic identifier, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$identifier'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ocurrió un error');
    }
  }

  Future<ApiResponse> createPost(
      int userId,
      int category,
      String title,
      String description,
      String html,
      List<String> allImages,
      String img,
      bool isPublished,
      String token) async {
    final response = await http.post(Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'user_id': userId,
          'category_id': category,
          'title': title,
          'content': description,
          'html': html,
          'image': img,
          'image_urls': allImages,
          'is_published': isPublished,
        }));

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      return ApiResponse(success: true, message: data['message']);
    } else {
      final error = json.decode(response.body);
      return ApiResponse(success: false, message: error['message']);
    }
  }

  Future<ApiResponse> updatePost(
      int postId,
      int category,
      String title,
      String description,
      String html,
      String img,
      List<String> allImages,
      bool isPublished,
      String token) async {
    final response = await http.put(Uri.parse('$baseUrl/$postId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'category_id': category,
          'title': title,
          'content': description,
          'html': html,
          'image': img,
          'image_urls': allImages,
          'is_published': isPublished,
        }));

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse(success: true, message: data['message']);
    } else {
      final error = json.decode(response.body);
      return ApiResponse(success: false, message: error['message']);
    }
  }

  Future<ApiResponse> addFavorite(int postId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$postId/favorite'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse(success: true, message: data['message']);
    } else {
      final error = json.decode(response.body);
      return ApiResponse(success: false, message: error['message']);
    }
  }

  Future<ApiResponse> removeFavorite(int postId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$postId/favorite'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse(success: true, message: data['message']);
    } else {
      final error = json.decode(response.body);
      return ApiResponse(success: false, message: error['message']);
    }
  }

  Future<ApiResponse> toggleBookmark(
      int postId, String token, bool isBookmarked) async {
    http.Response response;

    if (isBookmarked) {
      response = await http.delete(
        Uri.parse('$baseUrl/$postId/favorite'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
    } else {
      response = await http.post(
        Uri.parse('$baseUrl/$postId/favorite'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
    }

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      return ApiResponse(success: true, message: data['message']);
    } else {
      return ApiResponse(success: false, message: data['message']);
    }
  }

  Future<List<Post>> getFavorites(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Ocurrió un error: ${response.statusCode}');
    }
  }

  Future<ApiResponse> toggleLike(int postId, String token, bool isLiked) async {
    if (isLiked) {
      final response = await http.delete(
        Uri.parse('$baseUrl/$postId/like'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        final error = json.decode(response.body);
        return ApiResponse(success: false, message: error['message']);
      }
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/like'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        final error = json.decode(response.body);
        return ApiResponse(success: false, message: error['message']);
      }
    }
  }

  Future<ApiResponse> deletePost(int postId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ApiResponse(success: true, message: data['message']);
    } else {
      final error = json.decode(response.body);
      return ApiResponse(success: false, message: error['message']);
    }
  }
}
