import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:new_application_api/config.dart';

class PostPreviewCard extends StatelessWidget {
  final Post post;

  const PostPreviewCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig.baseStorageUrl;

    final profileImage = post.user.profileImage != null
        ? '$baseUrl/${post.user.profileImage}'
        : null;

    final formattedDate = post.createdAt.isNotEmpty
        ? timeago.format(DateTime.parse(post.createdAt), locale: 'es')
        : 'Unknown';

    return InkWell(
      onTap: () {
        context.push('/post/${post.id}');
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Texto del post
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.user.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.thumb_up, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        post.likesCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.comment, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        post.commentsCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Imagen del post
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.image!,
                  fit: BoxFit.cover,
                  height: 100,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.white60, size: 40),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white60, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
