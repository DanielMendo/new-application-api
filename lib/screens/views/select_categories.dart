import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/services/category_service.dart';
import 'package:new_application_api/models/category.dart';

class SelectCategoriesView extends StatefulWidget {
  final Category? selectedCategory;
  const SelectCategoriesView(this.selectedCategory, {super.key});

  @override
  State<SelectCategoriesView> createState() => _SelectCategoriesViewState();
}

class _SelectCategoriesViewState extends State<SelectCategoriesView> {
  Category? selectedCategory;

  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    futureCategories = CategoryService().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, selectedCategory);
          },
        ),
      ),
      body: FutureBuilder<List<Category>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          final categories = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorías',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Escoge la categoría que más identifique tu post. Esto será útil para que los lectores encuentren el post más relevante.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Categorías disponibles",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...categories.map((cat) => Column(
                        children: [
                          ListTile(
                            title: Text(cat.name),
                            trailing: selectedCategory?.name == cat.name
                                ? const Icon(Icons.check, color: Colors.black)
                                : null,
                            onTap: () {
                              setState(() {
                                selectedCategory = cat;
                              });
                              Navigator.pop(context, selectedCategory);
                            },
                          ),
                          const Divider(),
                        ],
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
