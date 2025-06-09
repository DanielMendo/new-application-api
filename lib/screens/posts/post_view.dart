import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/models/category.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/services/category_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:timeago/timeago.dart' as timeago;
import 'package:new_application_api/config.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  final dynamic postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post post;
  late Category category;
  String title = '';
  String name = '';
  String createAt = '';
  String delta = '';
  String content = '';
  late User user;
  bool isLoading = true;
  bool hasError = false;
  late quill.QuillController _controller;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  bool isBookmarked = false;
  bool isLiked = false;

  bool isProcessing = false;

  bool _showBottomBar = true;
  double _prevScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = quill.QuillController(
      document: quill.Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller.readOnly = true;
    _scrollController = ScrollController();
    _focusNode = FocusNode();
    _loadData();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final currentScrollOffset = _scrollController.offset;

      if (currentScrollOffset > _prevScrollOffset &&
          currentScrollOffset > 50.0) {
        if (_showBottomBar) {
          setState(() {
            _showBottomBar = false;
          });
        }
      } else if (currentScrollOffset < _prevScrollOffset &&
          currentScrollOffset <
              _scrollController.position.maxScrollExtent - 50.0) {
        if (!_showBottomBar) {
          setState(() {
            _showBottomBar = true;
          });
        }
      } else if (currentScrollOffset <= 0) {
        if (!_showBottomBar) {
          setState(() {
            _showBottomBar = true;
          });
        }
      }
      _prevScrollOffset = currentScrollOffset;
    }
  }

  Future<void> _loadData() async {
    await fetchPost();
    if (!hasError) {
      await fetchCategory();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPost() async {
    try {
      final post =
          await PostService().getPost(widget.postId, UserSession.token!);
      setState(() {
        this.post = post;
        user = post.user;
        title = post.title;
        name = post.user.name;
        createAt = post.createdAt;
        delta = post.html;
        content = post.content;
        isBookmarked = post.isBookmarked ?? false;
        isLiked = post.isLiked ?? false;
        try {
          _controller.document = quill.Document.fromJson(jsonDecode(delta));
        } catch (e) {
          hasError = true;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> fetchCategory() async {
    try {
      final category = await CategoryService().getCategory(post.categoryId);
      setState(() {
        this.category = category;
      });
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
  }

  void sharePost(String message) {
    Share.share(message);
  }

  void toggleBookmark() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
      isBookmarked = !isBookmarked;
    });

    final response = await PostService()
        .toggleBookmark(post.id, UserSession.token!, !isBookmarked);

    if (!response.success) {
      setState(() {
        isBookmarked = !isBookmarked;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar en favoritos')),
      );
    }

    setState(() {
      isProcessing = false;
    });
  }

  void toggleLike() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
      isLiked = !isLiked;
    });

    final response =
        await PostService().toggleLike(post.id, UserSession.token!, !isLiked);

    if (!response.success) {
      setState(() {
        isLiked = !isLiked;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar en favoritos')),
      );
    }

    setState(() {
      isProcessing = false;
    });
  }

  void _deletePost() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final response =
          await PostService().deletePost(post.id, UserSession.token!);

      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Post eliminado con éxito'),
            duration: Duration(seconds: 3),
          ),
        );

        if (mounted) {
          context.go('/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(response.message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el post: $e')),
      );
    }
  }

  int countWords(String text) {
    List<String> words =
        text.trim().split(' ').where((s) => s.isNotEmpty).toList();
    return words.length;
  }

  String calcularTiempoLectura(int numeroPalabras) {
    const int palabrasPorMinuto = 200;

    if (numeroPalabras <= 0) {
      return 'Menos de 1 minuto';
    }

    final double minutos = numeroPalabras / palabrasPorMinuto;
    final int minutosEnteros = minutos.floor();
    final int segundos = ((minutos - minutosEnteros) * 60).round();

    if (minutosEnteros == 0) {
      return 'Menos de 1 minuto';
    } else if (segundos < 30) {
      return '$minutosEnteros min';
    } else {
      return '${minutosEnteros + 1} min';
    }
  }

  String formatFecha(String fechaISO) {
    final fecha = DateTime.parse(fechaISO);
    final formato = DateFormat("d MMM", "es_ES");
    return formato.format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || delta.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Error al cargar el post')),
      );
    }

    final baseUrl = AppConfig.baseStorageUrl;

    final profileImage =
        user.profileImage != null ? '$baseUrl/${user.profileImage}' : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          if (user.id == UserSession.currentUser?.id)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              offset: Offset(0, kToolbarHeight),
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: Text(
                      'Editar',
                    ),
                    onTap: () => {
                          context.push('/edit-post',
                              extra: {'post': post, 'category': category})
                        }),
                PopupMenuItem(
                  child: const Text('Eliminar',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Confirmar eliminación',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: const Text(
                            '¿Estás seguro de que deseas eliminar este post? Esta acción no se puede deshacer.',
                            style: TextStyle(fontSize: 14),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text('Cancelar',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                _deletePost();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Eliminar',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(calcularTiempoLectura(countWords(content)),
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(" · ", style: TextStyle(color: Colors.grey)),
                    Text(
                      formatFecha(createAt),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    context.push('/profile',
                        extra: UserProfileView(user: user));
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: FadeInImage(
                            placeholder:
                                const AssetImage('assets/posts/avatar.png'),
                            image: profileImage != null
                                ? NetworkImage(profileImage)
                                : const AssetImage('assets/posts/avatar.png')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                            width: 76,
                            height: 76,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                quill.QuillEditor.basic(
                  controller: _controller,
                  focusNode: _focusNode,
                  config: quill.QuillEditorConfig(
                    showCursor: false,
                    scrollable: false,
                    embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                    customStyles: quill.DefaultStyles(
                      paragraph: quill.DefaultTextBlockStyle(
                        GoogleFonts.merriweather(
                          fontSize: 18.0,
                          color: Colors.black87,
                          height: 1.8,
                          fontWeight: FontWeight.w400,
                        ),
                        quill.HorizontalSpacing(8.0, 8.0),
                        quill.VerticalSpacing(0.0, 0.0),
                        quill.VerticalSpacing(0.0, 0.0),
                        null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showBottomBar ? kBottomNavigationBarHeight + 8 : 0,
        child: Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? PhosphorIcons.heartFill : PhosphorIcons.heart,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      toggleLike();
                    },
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIcons.chat, color: Colors.black),
                    onPressed: () {
                      context.push('/comments/${post.id}');
                    },
                  ),
                  IconButton(
                    icon: Icon(
                        isBookmarked
                            ? PhosphorIcons.bookmarkFill
                            : PhosphorIcons.bookmark,
                        color: Colors.black),
                    onPressed: () {
                      toggleBookmark();
                    },
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIcons.share, color: Colors.black),
                    onPressed: () {
                      final postUrl =
                          '${AppConfig.baseUrlWeb}/post/${post.slug ?? post.id}';
                      final shareMessage =
                          'Mira: "$title" en Bloogol: $postUrl';
                      sharePost(shareMessage);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
