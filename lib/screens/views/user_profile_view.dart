import 'package:flutter/material.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/models/profile.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/home/home_screen.dart';
import 'package:new_application_api/screens/layout/card_post.dart';
import 'package:new_application_api/screens/views/edit_profile.dart';
import 'package:new_application_api/screens/views/follower_following.dart';
import 'package:new_application_api/screens/views/user_settings_view.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/services/user_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserProfileView extends StatefulWidget {
  final User? user;
  final bool itsMe;

  const UserProfileView({
    super.key,
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
  final baseUrl = 'https://bloogol.com/storage/';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _postsFuture = _fetchPosts();
  }

  Future<void> _loadProfile() async {
    final userId =
        widget.itsMe ? UserSession.currentUser!.id! : widget.user!.id!;
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
    final userId =
        widget.itsMe ? UserSession.currentUser!.id! : widget.user!.id!;
    return PostService().getMyPosts(userId);
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
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          title: const Text("Profile",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          actions: [
            IconButton(
              icon: const Icon(PhosphorIcons.pencilSimple,
                  color: Colors.black, size: 22),
              onPressed: () async {
                final bool? changesMade = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfilePage()),
                );
                if (changesMade == true && context.mounted) {
                  _loadProfile();
                  (context.findAncestorStateOfType<HomeScreenState>())
                      ?.setState(() {});
                }
              },
            ),
            IconButton(
              icon:
                  const Icon(PhosphorIcons.gear, color: Colors.black, size: 22),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserSettingsView()),
              ),
            ),
          ],
        ),
        body: _buildContent(),
      );
    } else {
      return _buildContent();
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
            ? '$baseUrl${displayUser.profileImage}'
            : null)
        : profile.profileImage;

    return DefaultTabController(
      length: 2,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.itsMe)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      (context.findAncestorStateOfType<HomeScreenState>())
                          ?.setState(() {
                        (context.findAncestorStateOfType<HomeScreenState>())
                            ?.customBody = null;
                      });
                    },
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
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
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayUser.name,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FollowersFollowingView(
                                      userId: profile.id,
                                      showFollowers: true,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                  '${profile.followersCount} Seguidores',
                                  style: const TextStyle(fontSize: 15)),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FollowersFollowingView(
                                      userId: profile.id,
                                      showFollowers: false,
                                    ),
                                  ),
                                );
                              },
                              child: Text('${profile.followingCount} Siguiendo',
                                  style: const TextStyle(fontSize: 15)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        if (!widget.itsMe)
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
              tabs: [Tab(text: 'Posts'), Tab(text: 'About')],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                              itemCount: posts.length,
                              itemBuilder: (context, index) =>
                                  PostPreviewCard(post: posts[index]),
                              separatorBuilder: (context, index) =>
                                  Divider(color: Colors.grey.shade200),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Text(displayUser.bio ?? 'No hay información',
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
