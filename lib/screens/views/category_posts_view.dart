import 'package:flutter/material.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/screens/layout/card_post.dart';
import 'package:new_application_api/utils/user_session.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String categoryDescription;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryDescription,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    return PostService()
        .getPostsByCategory(widget.categoryId, UserSession.token!);
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
            child: Text(
              widget.categoryName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Descripción
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Text(
              widget.categoryDescription,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ),
          const Divider(),
          // Lista de Posts
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPosts,
              child: FutureBuilder<List<Post>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay publicaciones aún.'));
                  } else {
                    final posts = snapshot.data!;
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10.0),
                      itemCount: posts.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey.shade300),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostPreviewCard(post: post);
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
