import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';
import 'package:new_application_api/services/follow_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/config.dart';

class FollowersFollowingView extends StatefulWidget {
  final int userId;
  final bool showFollowers;

  const FollowersFollowingView({
    super.key,
    required this.userId,
    required this.showFollowers,
  });

  @override
  State<FollowersFollowingView> createState() => _FollowersFollowingViewState();
}

class _FollowersFollowingViewState extends State<FollowersFollowingView> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    if (widget.showFollowers) {
      _usersFuture =
          FollowService().getFollowers(widget.userId, UserSession.token!);
    } else {
      _usersFuture =
          FollowService().getFollowing(widget.userId, UserSession.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.showFollowers ? 'Seguidores' : 'Seguidos';
    final baseUrl = AppConfig.baseStorageUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return Center(child: Text('No hay $title'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(10.0),
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profileImage != null
                      ? NetworkImage('$baseUrl/${user.profileImage}')
                      : const AssetImage('assets/posts/avatar.png')
                          as ImageProvider,
                ),
                title: Text(user.name),
                subtitle: user.bio != null ? Text(user.bio!) : null,
                onTap: () {
                  context.go('/profile', extra: UserProfileView(user: user));
                },
              );
            },
          );
        },
      ),
    );
  }
}
