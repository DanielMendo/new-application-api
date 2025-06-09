import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/category.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/screens/layout/card_category.dart';
import 'package:new_application_api/screens/layout/card_post.dart';
import 'package:new_application_api/services/category_service.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/utils/user_session.dart';

class ExplorerView extends StatefulWidget {
  const ExplorerView({super.key});

  @override
  _ExplorerViewState createState() => _ExplorerViewState();
}

class _ExplorerViewState extends State<ExplorerView> {
  late Future<List<dynamic>> _initData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _initData = Future.wait([
      CategoryService().getCategories(),
      PostService().getAllPostsExclude(UserSession.currentUser!.id!),
    ]);
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadData();
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
          "Explorar",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<dynamic>>(
          future: _initData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("No se pudo cargar la información"));
            }

            final List<Category> categories =
                snapshot.data![0] as List<Category>;
            final List<Post> posts = snapshot.data![1] as List<Post>;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Título principal ---
                  const Text(
                    "Que sucede en el mundo",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Buscador ---
                  GestureDetector(
                    onTap: () {
                      context.push('/search');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search),
                          const SizedBox(width: 8),
                          const Text(
                            'Buscar...',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nuestras categorías",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/all-categories');
                        },
                        child: Text(
                          "Ver todas",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- Categorías ---
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryCard(category: category);
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- Recomended ---
                  const Text(
                    "Recomendado para ti",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Posts ---
                  if (posts.isEmpty)
                    const Text("No hay posts recomendados")
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
