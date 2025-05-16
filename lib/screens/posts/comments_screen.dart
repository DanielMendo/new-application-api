import 'package:flutter/material.dart';
import 'package:new_application_api/models/comment.dart';
import 'package:new_application_api/screens/posts/comment_view.dart';
import 'package:new_application_api/screens/posts/comments_input_view.dart';
import 'package:new_application_api/services/comment_service.dart';
import 'package:new_application_api/utils/user_session.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late Future<List<Comment>> _commentsFuture;
  String _selectedOrder = 'most_relevant';
  final TextEditingController _controller = TextEditingController();

  int? _replyToCommentId;
  String? _replyToUsername;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _commentsFuture = CommentService().fetchComments(
        widget.postId,
        UserSession.token!,
      );
    });
  }

  void _sendComment(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await CommentService().sendComment(
        postId: widget.postId,
        content: text,
        parentId: _replyToCommentId,
        token: UserSession.token!,
      );

      _controller.clear();
      setState(() {
        _replyToCommentId = null;
        _replyToUsername = null;
      });
      _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar el comentario')),
      );
    }
  }

  void _replyTo(int commentId, String username) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUsername = username;
    });
  }

  List<Widget> _buildCommentThread(List<Comment> comments, {int indent = 0}) {
    List<Widget> widgets = [];

    for (var comment in comments) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: indent.toDouble()),
          child: CommentItem(
            comment: comment,
            onReply: _replyTo,
            onDeleted: _loadComments, // <-- Lógica para refrescar
          ),
        ),
      );

      if (comment.replies.isNotEmpty) {
        widgets
            .addAll(_buildCommentThread(comment.replies, indent: indent + 32));
      }

      widgets.add(const Divider());
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filtro de orden
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedOrder,
              items: const [
                DropdownMenuItem(
                    value: 'most_relevant', child: Text('Most Relevant')),
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _selectedOrder = value;
                  _loadComments();
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),

          // Comentarios
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar comentarios'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Sin comentarios aún.'));
                }

                final allComments = snapshot.data!;
                return ListView(
                  children: _buildCommentThread(allComments),
                );
              },
            ),
          ),

          // Input de comentario
          CommentInput(
            controller: _controller,
            onSend: _sendComment,
            replyingTo: _replyToUsername,
            onCancelReply: () {
              setState(() {
                _replyToCommentId = null;
                _replyToUsername = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
