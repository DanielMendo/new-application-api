import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/category.dart';
import 'package:new_application_api/config.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final String baseUrl = AppConfig.baseStorageUrl;

  CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          context.push('/category-detail', extra: {
            'categoryId': category.id,
            'categoryName': category.name,
            'categoryDescription': category.description,
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  '$baseUrl/${category.image}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey,
                    child:
                        Icon(Icons.broken_image, size: 60, color: Colors.white),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              Center(
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
