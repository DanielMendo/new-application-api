import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/screens/layout/card_post.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:new_application_api/services/notification_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Post>> _postsFuture;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
    _loadUnreadNotifications();
  }

  Future<List<Post>> _fetchPosts() async {
    final postService = PostService();
    return postService.getAllPostsFollowing(UserSession.token!);
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final notificationService = NotificationService();
      final count =
          await notificationService.getUnreadCount(UserSession.token!);
      setState(() {
        unreadCount = count;
      });
    } catch (e) {
      print("Error al obtener notificaciones no leídas: $e");
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _fetchPosts();
      _loadUnreadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              context.push('/notifications');
              setState(() {
                unreadCount = 0;
              });
            },
            icon: Badge.count(
                count: unreadCount,
                child: const Icon(PhosphorIcons.bell,
                    color: Colors.black, size: 22)),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Comienza aquí",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPosts,
                child: FutureBuilder<List<Post>>(
                  future: _postsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Sigue a alguien para ver sus posts'));
                    }
                    final posts = snapshot.data!;
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostPreviewCard(post: post);
                      },
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
