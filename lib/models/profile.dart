class UserProfile {
  final int id;
  final String name;
  final String? profileImage;
  int followersCount;
  int followingCount;
  bool isFollowing;

  UserProfile({
    required this.id,
    required this.name,
    this.profileImage,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      profileImage: json['profile_image'],
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
      isFollowing: json['is_following'],
    );
  }
}
