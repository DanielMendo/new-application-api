import 'package:new_application_api/models/user.dart';

class Post {
  final int id;
  final User user;
  final int categoryId;
  final String title;
  final String content;
  final String html;
  final String? image;
  final int isPublished;
  final bool? isBookmarked;
  final bool? isLiked;
  final int? likesCount;
  final int? commentsCount;
  final String createdAt;

  Post({
    required this.id,
    required this.user,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.html,
    this.image,
    required this.isPublished,
    this.isBookmarked,
    this.isLiked,
    this.likesCount,
    this.commentsCount,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: int.parse(json['id'].toString()),
      user: User.fromJson(json['user']),
      categoryId: int.parse(json['category_id'].toString()),
      title: json['title'],
      content: json['content'],
      html: json['html'],
      image: json['image'],
      isPublished: json['is_published'],
      isBookmarked: json['is_bookmarked'],
      isLiked: json['is_liked'],
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      createdAt: json['created_at'],
    );
  }
}
