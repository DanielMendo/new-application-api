import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/category.dart';
import 'package:new_application_api/screens/layout/card_category.dart';
import 'package:new_application_api/services/category_service.dart';

class AllCategoriesView extends StatefulWidget {
  const AllCategoriesView({super.key});

  @override
  State<AllCategoriesView> createState() => _AllCategoriesViewState();
}

class _AllCategoriesViewState extends State<AllCategoriesView> {
  late Future<List<Category>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    return CategoryService().getCategories();
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _categories = _fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<List<Category>>(
        future: _categories,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;
          final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;

          return RefreshIndicator(
            onRefresh: _refreshCategories,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Categorías",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Explore todas las categorías disponibles en Bloogol, para encontrar las publicaciones que más te interesan.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 40),

                  // Dinámico (solo este se recarga con refresh)
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (hasError)
                    Center(child: Text('Error: ${snapshot.error}'))
                  else if (!hasData)
                    const Center(child: Text('No hay categorías disponibles.'))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        return CategoryCard(category: category);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
