import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/screens/views/select_categories.dart';

class PreviewPostView extends StatefulWidget {
  final String title;
  final String description;
  final String? image;
  final String html;
  String? selectedCategory;

  PreviewPostView(
      {super.key,
      required this.title,
      required this.description,
      this.selectedCategory,
      required this.html,
      this.image});

  @override
  State<PreviewPostView> createState() => _PreviewPostViewState();
}

class _PreviewPostViewState extends State<PreviewPostView> {
  bool isUnlisted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Previsualización',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/posts/avatar.png'),
                            radius: 12,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'J Daniel M Mendoza',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.title.length > 100
                            ? '${widget.title.substring(0, 100)}...'
                            : widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.description.length > 100
                            ? '${widget.description.substring(0, 100)}...'
                            : widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.image ?? '',
                      )
                    ],
                  )),
            ),
            SizedBox(height: 15),
            ListTile(
                title: Text('Categoría',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                    widget.selectedCategory ?? 'Categoría no seleccionada'),
                trailing: Icon(Icons.chevron_right),
                onTap: () async {
                  final selectedCategory = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SelectCategoriesView(widget.selectedCategory),
                    ),
                  );

                  if (selectedCategory != null) {
                    setState(() {
                      // Guarda la categoría seleccionada en la vista actual
                      widget.selectedCategory = selectedCategory;
                    });
                  }
                }),
            Divider(),
            ListTile(
              title: Text('Privacidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('Privacidad no seleccionada'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              title: Text('Unlisted Story',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: Switch(
                value: isUnlisted,
                onChanged: (value) {
                  setState(() {
                    isUnlisted = value;
                  });
                },
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Acción de publicar
                },
                child: Text(
                  'Publish now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
