import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/services/unsplash_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UnsplashSearchPage extends StatefulWidget {
  const UnsplashSearchPage({super.key});

  @override
  _UnsplashSearchPageState createState() => _UnsplashSearchPageState();
}

class _UnsplashSearchPageState extends State<UnsplashSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final UnsplashService _unsplashService = UnsplashService();

  List<String> _imageUrls = [];
  bool _loading = false;
  bool _isSearching = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchImages("random");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchImages(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      final images = await _unsplashService.searchUnsplashImages(
          UserSession.token!, query);
      setState(() {
        _imageUrls = images;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchImages(query);
    });
  }

  void _toggleSearch() {
    setState(() => _isSearching = !_isSearching);
    if (!_isSearching) {
      _controller.clear();
      _imageUrls.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'Buscar en Unsplash...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(PhosphorIcons.magnifyingGlass),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 18),
              )
            : const Text(
                'Unsplash',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(PhosphorIcons.magnifyingGlass),
              onPressed: _toggleSearch,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_loading)
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: 14,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: _imageUrls.isEmpty
                  ? const Center(child: Text('No hay resultados'))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        final imageUrl = _imageUrls[index];
                        return GestureDetector(
                          onTap: () {
                            context.pop(imageUrl);
                          },
                          child: ClipRRect(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
            )
        ],
      ),
    );
  }
}
