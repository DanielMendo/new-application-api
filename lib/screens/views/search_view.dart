import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/layout/card_post.dart';
import 'package:new_application_api/screens/layout/card_user.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/services/user_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  Future<List<Post>>? _postsFuture;
  Future<List<User>>? _usersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.length < 2) {
      setState(() {
        _postsFuture = null;
        _usersFuture = null;
      });
      return;
    }

    setState(() {
      _postsFuture = PostService().searchPosts(query, UserSession.token!);
      _usersFuture = UserService().searchUsers(query, UserSession.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () {
            context.pop();
          },
        ),
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: true,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            hintText: 'Buscar...',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(PhosphorIcons.magnifyingGlass),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          ),
        ),
        bottom: TabBar(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Publicaciones'),
            Tab(text: 'Personas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _postsFuture == null
              ? const Center(child: Text('Empieza una búsqueda...'))
              : FutureBuilder<List<Post>>(
                  future: _postsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
          _usersFuture == null
              ? const Center(child: Text('Empieza una búsqueda...'))
              : FutureBuilder<List<User>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No se encontraron personas'));
                    } else {
                      final users = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: users.length,
                        itemBuilder: (context, index) =>
                            UserPreviewCard(user: users[index]),
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }
}
