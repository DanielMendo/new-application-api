import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/comment.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';
import 'package:new_application_api/services/comment_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:new_application_api/config.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final void Function(int, String)? onReply;
  final VoidCallback? onDeleted;

  const CommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.onDeleted,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  late bool isLiked;
  late int likes;

  @override
  void initState() {
    super.initState();
    isLiked = widget.comment.isLiked;
    likes = widget.comment.likes;
  }

  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likes += isLiked ? 1 : -1;
    });

    try {
      await CommentService()
          .toggleLike(widget.comment.id, UserSession.token!, !isLiked);
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
        likes += isLiked ? 1 : -1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al dar like')),
      );
    }
  }

  void _deleteComment(BuildContext context) async {
    try {
      await CommentService()
          .deleteComment(widget.comment.id, UserSession.token!);
      widget.onDeleted?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el comentario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig.baseStorageUrl;

    final formattedDate = widget.comment.createdAt.isNotEmpty
        ? timeago.format(DateTime.parse(widget.comment.createdAt))
        : 'Ahora';

    return ListTile(
      leading: GestureDetector(
        onTap: () {
          context.push('/profile',
              extra: UserProfileView(user: widget.comment.user));
        },
        child: widget.comment.profileImageUrl != null
            ? CircleAvatar(
                backgroundImage:
                    NetworkImage('$baseUrl/${widget.comment.profileImageUrl}'))
            : const CircleAvatar(
                backgroundImage: AssetImage('assets/posts/avatar.png'),
              ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.push('/profile',
                  extra: UserProfileView(user: widget.comment.user));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.comment.name, style: const TextStyle(fontSize: 13)),
                Text(formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (widget.comment.userId == UserSession.currentUser?.id)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Eliminar',
                      style: TextStyle(color: Colors.red)),
                  onTap: () => Future.delayed(
                      Duration.zero, () => _deleteComment(context)),
                ),
              ],
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Text(widget.comment.content),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? Colors.black : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text('$likes', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${widget.comment.replies.length}',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 16),
              if (widget.comment.parentId == null)
                TextButton(
                  onPressed: () => widget.onReply
                      ?.call(widget.comment.id, widget.comment.name),
                  child: const Text('Responder',
                      style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
