class User {
  final int? id;
  final String name;
  final String? phone;
  final String lastName;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastName,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'phone': phone,
      'email': email,
    };
  }
}
