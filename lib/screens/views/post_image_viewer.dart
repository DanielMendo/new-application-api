// lib/screens/views/image_viewer_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final String? initialSelectedImage;

  const ImageViewerScreen({
    super.key,
    required this.imageUrls,
    this.initialSelectedImage,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialSelectedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () {
                context.pop(_selectedImage);
              },
              child: const Text('Hecho', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Miniatura',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 16),
              Expanded(
                child: widget.imageUrls.isEmpty
                    ? const Center(child: Text('No hay imágenes para mostrar.'))
                    : GridView.builder(
                        padding: const EdgeInsets.only(top: 16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: widget.imageUrls.length,
                        itemBuilder: (context, index) {
                          final imageUrl = widget.imageUrls[index];
                          final isSelected = _selectedImage == imageUrl;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = imageUrl;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.blueAccent
                                              .withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[300],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey, size: 40),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ])));
  }
}
