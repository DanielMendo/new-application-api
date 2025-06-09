import 'package:flutter/material.dart';

class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String text) onSend;
  final String? replyingTo;
  final VoidCallback? onCancelReply;

  const CommentInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.replyingTo,
    this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyingTo != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  Text('Respondiendo a @$replyingTo',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    onSend(controller.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
