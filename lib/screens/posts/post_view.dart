import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_application_api/screens/posts/comments_screen.dart';
// import 'package:new_application_api/screens/posts/comments_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:new_application_api/screens/home/home_screen.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';
import 'package:new_application_api/services/post_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  String title = '';
  String name = '';
  String createAt = '';
  String delta = '';
  late User user;
  bool isLoading = true;
  bool hasError = false;
  late quill.QuillController _controller;
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  bool isBookmarked = false;
  bool isLiked = false;

  bool isProcessing = false;

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
    fetchPost();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchPost() async {
    try {
      final post =
          await PostService().getPost(widget.postId, UserSession.token!);
      setState(() {
        user = post.user;
        title = post.title;
        name = post.user.name;
        createAt = post.createdAt;
        delta = post.html;
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

  void sharePost(String title, String url) {
    Share.share('$title\n\n$url');
  }

  void toggleBookmark() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
      isBookmarked = !isBookmarked;
    });

    final response = await PostService()
        .toggleBookmark(widget.postId, UserSession.token!, !isBookmarked);

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

    final response = await PostService()
        .toggleLike(widget.postId, UserSession.token!, !isLiked);

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

  // void _showCommentsModal() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return DraggableScrollableSheet(
  //         expand: false,
  //         initialChildSize: 0.8,
  //         minChildSize: 0.4,
  //         maxChildSize: 0.95,
  //         builder: (_, controller) => CommentsView(
  //           postId: widget.postId,
  //           scrollController: controller,
  //         ),
  //       );
  //     },
  //   );
  // }

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

    final formattedDate = createAt.isNotEmpty
        ? timeago.format(DateTime.parse(createAt))
        : 'Unknown';

    final baseUrl = 'https://bloogol.com/storage/';

    final profileImage =
        user.profileImage != null ? '$baseUrl${user.profileImage}' : null;

    // final isMine = user.id == UserSession.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            customBody: UserProfileView(
                              user: user,
                            ),
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Column(
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
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: quill.QuillEditor.basic(
                  controller: _controller,
                  scrollController: _scrollController,
                  focusNode: _focusNode,
                  config: quill.QuillEditorConfig(
                    embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentsScreen(postId: widget.postId),
                  ),
                );
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
                    'https://bloogol.com/api/posts/${widget.postId}';
                sharePost(title, postUrl);
              },
            ),
          ],
        ),
      ),
    );
  }
}
