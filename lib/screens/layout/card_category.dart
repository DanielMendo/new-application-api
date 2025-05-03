import 'package:flutter/material.dart';

class Category {
  final String title;
  final Color color;
  final IconData icon;

  Category({required this.title, required this.color, required this.icon});
}

List<Category> categories = [
  Category(
      title: 'Tech News & Trends', color: Colors.purple, icon: Icons.memory),
  Category(
      title: 'Business & Finance',
      color: Colors.teal,
      icon: Icons.attach_money),
  Category(
      title: 'Industry Insights', color: Colors.indigo, icon: Icons.insights),
  Category(title: 'Skills & Learning', color: Colors.red, icon: Icons.school),
  Category(
      title: 'Hobby & Lifestyle',
      color: Colors.green,
      icon: Icons.self_improvement),
  Category(title: 'Sports', color: Colors.lightBlue, icon: Icons.sports_soccer),
];

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          category.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
