import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/models/category.dart';

class PreviewPostView extends StatefulWidget {
  bool? isEditing;
  int? postId;
  final Category? initialSelectedCategory;
  bool? privacy = true;
  final String title;
  final String description;
  final String html;
  final String? initialImageUrl;
  final List<String> allImages;

  PreviewPostView({
    super.key,
    this.isEditing,
    this.postId,
    this.initialSelectedCategory,
    this.privacy,
    required this.title,
    required this.description,
    required this.html,
    this.initialImageUrl,
    required this.allImages,
  });

  @override
  State<PreviewPostView> createState() => _PreviewPostViewState();
}

class _PreviewPostViewState extends State<PreviewPostView> {
  Category? _selectedCategory;
  bool? _privacy;
  String? _currentThumbnail;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialSelectedCategory;
    _privacy = widget.privacy;
    _currentThumbnail = widget.initialImageUrl;
  }

  Future<void> _createPost() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una categoría')),
      );
      return;
    }
    if (_currentThumbnail == null || _currentThumbnail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor selecciona una imagen para la miniatura')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await PostService().createPost(
          UserSession.currentUser!.id!,
          _selectedCategory!.id,
          widget.title,
          widget.description,
          widget.html,
          widget.allImages,
          _currentThumbnail!,
          _privacy ?? true,
          UserSession.token!);

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                const Icon(Iconsax.edit, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );

        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al publicar el post: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePost() async {
    if (_currentThumbnail == null || _currentThumbnail!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor selecciona una imagen para la miniatura')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await PostService().updatePost(
        widget.postId!,
        _selectedCategory!.id,
        widget.title,
        widget.description,
        widget.html,
        _currentThumbnail!,
        widget.allImages,
        _privacy ?? true,
        UserSession.token!,
      );
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                const Icon(Iconsax.edit, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Publicación actualizada",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Text("Publicación actualizada con éxito",
                        style: TextStyle(color: Colors.white, fontSize: 12))
                  ],
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(12),
          ),
        );
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 2),
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
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Previsualización',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 20),
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
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/posts/avatar.png'),
                          radius: 12,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${UserSession.currentUser!.name} ${UserSession.currentUser!.lastName ?? ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final newThumbnail = await context.push<String>(
                          '/image-viewer',
                          extra: {
                            'imageUrls': widget.allImages,
                            'initialSelectedImage': _currentThumbnail,
                          },
                        );
                        if (newThumbnail != null &&
                            newThumbnail != _currentThumbnail) {
                          setState(() {
                            _currentThumbnail = newThumbnail;
                          });
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title.length > 100
                                      ? '${widget.title.substring(0, 100)}...'
                                      : widget.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 10),
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
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 100,
                            height: 80,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    _currentThumbnail!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey[300],
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                                // Icono para indicar que se puede cambiar
                                const Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
                title: const Text('Categoría',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                    _selectedCategory?.name ?? 'Categoría no seleccionada'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final selectedCategoryFromRoute =
                      await context.push<Category>(
                    '/select-category',
                    extra: _selectedCategory,
                  );

                  if (selectedCategoryFromRoute != null) {
                    setState(() {
                      _selectedCategory = selectedCategoryFromRoute;
                    });
                  }
                }),
            const Divider(),
            ListTile(
              title: const Text('Privacidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(_privacy == null
                  ? 'Privacidad no seleccionada'
                  : (_privacy! ? 'Público' : 'Privado')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final privacyFromRoute = await context.push<bool>(
                  '/select-privacy',
                  extra: _privacy,
                );

                if (privacyFromRoute != null) {
                  setState(() {
                    _privacy = privacyFromRoute;
                  });
                }
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (widget.isEditing == true) {
                    _updatePost();
                  } else {
                    _createPost();
                  }
                },
                child: const Text(
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
