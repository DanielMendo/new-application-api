import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/models/profile.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/layout/card_post.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/services/user_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:new_application_api/config.dart';

class UserProfileView extends StatefulWidget {
  final int? userId;
  final User? user;
  final bool itsMe;

  const UserProfileView({
    super.key,
    this.userId,
    this.user,
    this.itsMe = false,
  });

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late Future<List<Post>> _postsFuture;
  UserProfile? _userProfileData;
  bool _isLoadingProfile = true;
  final baseUrl = AppConfig.baseStorageUrl;
  String _selectedVisibility = 'public';
  late bool itsMe;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _postsFuture = _fetchPosts();
    itsMe = _userProfileData?.id == UserSession.currentUser?.id;
  }

  Future<void> _loadProfile() async {
    final userId = widget.userId ??
        (widget.itsMe ? UserSession.currentUser!.id! : widget.user!.id!);
    final profile =
        await UserService().fetchUserProfile(userId, UserSession.token!);
    if (mounted) {
      setState(() {
        _userProfileData = profile;
        _isLoadingProfile = false;
      });
    }
  }

  Future<List<Post>> _fetchPosts() async {
    final userId = widget.userId ??
        (widget.itsMe ? UserSession.currentUser!.id! : widget.user!.id!);
    return PostService()
        .getMyPosts(userId, UserSession.token!, _selectedVisibility);
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _fetchPosts();
    });
  }

  void _toggleFollow() async {
    if (_userProfileData == null) return;

    final userId = _userProfileData!.id;
    final token = UserSession.token!;
    setState(() {
      _userProfileData!.isFollowing = !_userProfileData!.isFollowing;
      _userProfileData!.followersCount +=
          _userProfileData!.isFollowing ? 1 : -1;
    });

    try {
      if (_userProfileData!.isFollowing) {
        await UserService().follow(userId, token);
      } else {
        await UserService().unfollow(userId, token);
      }
    } catch (e) {
      // Revert changes in case of error
      setState(() {
        _userProfileData!.isFollowing = !_userProfileData!.isFollowing;
        _userProfileData!.followersCount +=
            _userProfileData!.isFollowing ? 1 : -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itsMe) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          title: const Text("Perfil",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          actions: [
            IconButton(
              icon: const Icon(PhosphorIcons.pencilSimple,
                  color: Colors.black, size: 22),
              onPressed: () async {
                final bool? changesMade = await context.push('/edit-profile');
                if (changesMade == true && context.mounted) {
                  _loadProfile();
                }
              },
            ),
            IconButton(
              icon:
                  const Icon(PhosphorIcons.gear, color: Colors.black, size: 22),
              onPressed: () => context.push('/user-settings'),
            ),
          ],
        ),
        body: _buildContent(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
          automaticallyImplyLeading: false,
        ),
        body: _buildContent(),
      );
    }
  }

  Widget _buildContent() {
    if (_isLoadingProfile || _userProfileData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = _userProfileData!;
    final displayUser = widget.itsMe ? UserSession.currentUser! : widget.user!;
    final profileImage = widget.itsMe
        ? (displayUser.profileImage != null
            ? '$baseUrl/${displayUser.profileImage}'
            : null)
        : (profile.profileImage != null
            ? '$baseUrl/${profile.profileImage}'
            : null);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (profileImage != null) {
                      context.push('/profile-image', extra: {
                        'imageUrl': profileImage,
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: FadeInImage(
                        placeholder:
                            const AssetImage('assets/posts/avatar.png'),
                        image: profileImage != null
                            ? NetworkImage(profileImage)
                            : const AssetImage('assets/posts/avatar.png')
                                as ImageProvider,
                        fit: BoxFit.cover,
                        width: 76,
                        height: 76,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.push('/followers-following', extra: {
                                'userId': profile.id,
                                'showFollowers': true
                              });
                            },
                            child: Text('${profile.followersCount} Seguidores',
                                style: const TextStyle(fontSize: 15)),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push('/followers-following', extra: {
                                'userId': profile.id,
                                'showFollowers': false
                              });
                            },
                            child: Text('${profile.followingCount} Siguiendo',
                                style: const TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (!widget.itsMe &&
                          profile.id != UserSession.currentUser?.id)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: profile.isFollowing
                                  ? Colors.red.shade900
                                  : Theme.of(context).primaryColor,
                            ),
                            onPressed: _toggleFollow,
                            child: Text(
                              profile.isFollowing
                                  ? 'Dejar de seguir'
                                  : 'Seguir',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [Tab(text: 'Publicaciones'), Tab(text: 'Información')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Column(
                  children: [
                    if (widget.itsMe &&
                        profile.id == UserSession.currentUser?.id)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 10.0),
                        child: Row(
                          children: [
                            const Text("Filtrar:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            DropdownButton2<String>(
                              value: _selectedVisibility,
                              items: const [
                                DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'Todos',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                DropdownMenuItem(
                                    value: 'public',
                                    child: Text(
                                      'Públicos',
                                      style: TextStyle(fontSize: 14),
                                    )),
                                DropdownMenuItem(
                                    value: 'private',
                                    child: Text(
                                      'Privados',
                                      style: TextStyle(fontSize: 14),
                                    )),
                              ],
                              onChanged: (value) {
                                if (value != null &&
                                    value != _selectedVisibility) {
                                  setState(() {
                                    _selectedVisibility = value;
                                    _refreshPosts();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                        child: RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: FutureBuilder<List<Post>>(
                        future: _postsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('No hay posts'));
                          } else {
                            final posts = snapshot.data!;
                            return ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(10.0),
                              itemCount: posts.length,
                              itemBuilder: (context, index) =>
                                  PostPreviewCard(post: posts[index]),
                              separatorBuilder: (context, index) =>
                                  Divider(color: Colors.grey.shade200),
                            );
                          }
                        },
                      ),
                    ))
                  ],
                ),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(22.0),
                  child: Text(displayUser.bio ?? 'No hay información',
                      style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
