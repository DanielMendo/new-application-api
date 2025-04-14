import 'package:flutter/material.dart';
import 'models/user.dart';
import 'models/post.dart';
import 'services/user_service.dart';
import 'services/post_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Publicaciones',
      home: PostList(),
    );
  }
}

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  
  // ignore: library_private_types_in_public_api
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final PostService postService = PostService();
  final UserService userService = UserService();
  late Future<List<Post>> posts;

  @override
  void initState() {
    super.initState();
    posts = postService.getPosts();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Últimos posts')),
      body: FutureBuilder<List<Post>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Post post = snapshot.data![index];
                return FutureBuilder<User>(
                  future: userService.getUser(post.userId), 
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasData) {
                      User user = userSnapshot.data!;
                      return ListTile(
                        title: Text(post.titulo),
                        subtitle: Text('Por: ${user.name} ${user.lastName}'),
                      );
                    } else if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text(post.titulo),
                        subtitle: Text('Error: ${userSnapshot.error}'),
                      );
                    }
                    return ListTile(
                      title: Text(post.titulo),
                      subtitle: Text('Cargando usuario...'),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
