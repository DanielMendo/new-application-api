class User {
  final int id;
  final String nombre;
  final String apellidos;
  final String email;

  User({
    required this.id, 
    required this.nombre, 
    required this.apellidos, 
    required this.email
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      email: json['email'],
    );
  }
}