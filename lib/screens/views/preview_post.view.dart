import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/screens/home/home_screen.dart';
import 'package:new_application_api/screens/views/select_categories.dart';
import 'package:new_application_api/screens/views/select_privacy.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/models/category.dart';

class PreviewPostView extends StatefulWidget {
  Category? selectedCategory;
  bool? privacy;
  final String title;
  final String description;
  final String html;
  final String? image;

  PreviewPostView(
      {super.key,
      this.selectedCategory,
      this.privacy,
      required this.title,
      required this.description,
      required this.html,
      this.image});

  @override
  State<PreviewPostView> createState() => _PreviewPostViewState();
}

class _PreviewPostViewState extends State<PreviewPostView> {
  bool isUnlisted = false;

  Future<void> _createPost() async {
    if (widget.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una categoría')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await PostService().createPost(
          UserSession.currentUser!.id!,
          widget.selectedCategory!.id,
          widget.title,
          widget.description,
          widget.html,
          widget.image ?? '',
          true,
          UserSession.token!);

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                Icon(Iconsax.edit, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Publicación publicada",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text("Publicación creada con éxito",
                        style: TextStyle(color: Colors.white, fontSize: 12))
                  ],
                ),
              ],
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(12),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                              '${UserSession.currentUser!.name} ${UserSession.currentUser!.lastName ?? ''}',
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
                    ],
                  )),
            ),
            SizedBox(height: 15),
            ListTile(
                title: Text('Categoría',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(widget.selectedCategory?.name ??
                    'Categoría no seleccionada'),
                trailing: Icon(Icons.chevron_right),
                onTap: () async {
                  final selectedCategory = await Navigator.push<Category>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SelectCategoriesView(widget.selectedCategory),
                    ),
                  );

                  if (selectedCategory != null) {
                    setState(() {
                      widget.selectedCategory = selectedCategory;
                    });
                  }
                }),
            Divider(),
            ListTile(
              title: Text('Privacidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(widget.privacy == null
                  ? 'Privacidad no seleccionada'
                  : (widget.privacy! ? 'Público' : 'Privado')),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                final privacy = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelectPrivacyView(widget.privacy)),
                );

                if (privacy != null) {
                  setState(() {
                    widget.privacy = privacy;
                  });
                }
              },
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
                  _createPost();
                },
                child: Text(
                  'Publicar ahora',
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
