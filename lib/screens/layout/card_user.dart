import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/config.dart';
import 'package:new_application_api/models/user.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';

class UserPreviewCard extends StatelessWidget {
  final User user;

  const UserPreviewCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = AppConfig.baseStorageUrl;
    final imageProvider =
        (user.profileImage != null && user.profileImage!.isNotEmpty)
            ? NetworkImage('$baseUrl/${user.profileImage}')
            : const AssetImage('assets/posts/avatar.png') as ImageProvider;

    return GestureDetector(
      onTap: () {
        context.push('/profile', extra: UserProfileView(user: user));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: imageProvider,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.bio?.isNotEmpty == true
                        ? user.bio!
                        : 'Sin descripción',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
