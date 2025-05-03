import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SelectCategoriesView extends StatefulWidget {
  final String? selectedCategory;
  const SelectCategoriesView(this.selectedCategory, {super.key});

  @override
  State<SelectCategoriesView> createState() => _SelectCategoriesViewState();
}

class _SelectCategoriesViewState extends State<SelectCategoriesView> {
  String? selectedCategory;

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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Escoge la categoría que más identifique tu post. Esto será útil para que los lectores encuentren el post más relevante.',
                style: TextStyle(color: Colors.black87),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'Buscar...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text("Categorías disponibles",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ListTile(
                title: Text('Arte'),
                trailing: selectedCategory == 'Arte' ||
                        widget.selectedCategory == 'Arte'
                    ? Icon(Icons.check, color: Colors.black)
                    : null,
                onTap: () {
                  setState(() {
                    selectedCategory = 'Arte';
                  });
                  Navigator.pop(context, selectedCategory);
                },
              ),
              Divider(),
              ListTile(
                title: Text('Ciencia'),
                trailing: selectedCategory == 'Ciencia' ||
                        widget.selectedCategory == 'Ciencia'
                    ? Icon(Icons.check, color: Colors.black)
                    : null,
                onTap: () {
                  setState(() {
                    selectedCategory = 'Ciencia';
                  });
                  Navigator.pop(context, selectedCategory);
                },
              ),
              Divider(),
              ListTile(
                title: Text('Cultura'),
                trailing: selectedCategory == 'Cultura' ||
                        widget.selectedCategory == 'Cultura'
                    ? Icon(Icons.check, color: Colors.black)
                    : null,
                onTap: () {
                  setState(() {
                    selectedCategory = 'Cultura';
                  });
                  Navigator.pop(context, selectedCategory);
                },
              )
            ],
          ),
        ));
  }
}
