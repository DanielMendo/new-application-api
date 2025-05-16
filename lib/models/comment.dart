class Comment {
  final int id;
  final int? parentId;
  final int userId;
  final String name;
  final String profileImageUrl;
  final String content;
  final String createdAt;
  final int likes;
  final bool isLiked;
  final List<Comment> replies;

  Comment({
    required this.id,
    this.parentId,
    required this.userId,
    required this.name,
    required this.profileImageUrl,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.isLiked,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      parentId: json['parent_id'],
      userId: json['user']['id'],
      name: json['user']['name'],
      profileImageUrl: json['user']['profile_image'],
      content: json['content'],
      createdAt: json['created_at'],
      likes: json['likes'],
      isLiked: json['is_liked'],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => Comment.fromJson(r))
              .toList() ??
          [],
    );
  }
}
