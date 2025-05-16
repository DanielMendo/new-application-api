import 'package:flutter/material.dart';
import 'package:new_application_api/models/comment.dart';
import 'package:new_application_api/services/comment_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget {
  final Comment comment;
  final void Function(int, String)? onReply;
  final VoidCallback? onDeleted;

  const CommentItem({
    super.key,
    required this.comment,
    this.onReply,
    this.onDeleted,
  });

  void _deleteComment(BuildContext context) async {
    try {
      await CommentService().deleteComment(comment.id, UserSession.token!);

      onDeleted?.call();

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
    final baseUrl = 'https://bloogol.com/storage/';

    final formattedDate = comment.createdAt.isNotEmpty
        ? timeago.format(DateTime.parse(comment.createdAt))
        : 'Ahora';

    return ListTile(
      leading: CircleAvatar(
          backgroundImage: NetworkImage('$baseUrl${comment.profileImageUrl}')
              as ImageProvider),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.name, style: const TextStyle(fontSize: 13)),
              Text(formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 18),
            itemBuilder: (context) => [
              if (comment.parentId == null)
                PopupMenuItem(
                  child: const Text('Responder'),
                  onTap: () => onReply?.call(comment.id, comment.name),
                ),
              if (comment.userId == UserSession.currentUser?.id)
                PopupMenuItem(
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    // Esto lo hacemos después para evitar error de "setState" o "context" en onTap directo.
                    Future.delayed(
                        Duration.zero, () => _deleteComment(context));
                  },
                ),
            ],
          )
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Text(comment.content),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${comment.likes}'),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${comment.replies.length}'),
              const SizedBox(width: 16),
              if (comment.parentId == null)
                TextButton(
                  onPressed: () => onReply?.call(comment.id, comment.name),
                  child: const Text('Responder'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
