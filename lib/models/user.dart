class User {
  final int? id;
  final String name;
  final String? lastName;
  final String? phone;
  final String email;
  final String? profileImage;
  final String? bio;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastName,
    required this.email,
    this.profileImage,
    this.bio,
  });

  User copyWith() {
    return User(
      id: id,
      name: name,
      lastName: lastName,
      phone: phone,
      email: email,
      profileImage: profileImage,
      bio: bio,
    );
  }

  User copyWithProfile({
    String? name,
    String? lastName,
    String? bio,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phone: phone,
      email: email,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  User copyWithEmail(String email) {
    return User(
      id: id,
      name: name,
      lastName: lastName,
      phone: phone,
      email: email,
      profileImage: profileImage,
      bio: bio,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      profileImage: json['profile_image'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'profile_image': profileImage,
      'bio': bio,
    };
  }
}
