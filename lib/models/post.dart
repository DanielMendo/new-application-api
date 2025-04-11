class Post {
  final int id;
  final String titulo;
  final String contenido;
  final int userId;

  Post({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: int.parse(json['id'].toString()),
      titulo: json['titulo'],
      contenido: json['contenido'],
      userId: int.parse(json['user_id'].toString()),
    );
  }
}