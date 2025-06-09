import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';
import 'package:new_application_api/services/notification_service.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/models/notification.dart';
import 'package:new_application_api/config.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final NotificationService _notificationService = NotificationService();

  List<Notify> notifications = [];
  int unreadCount = 0;
  bool loading = true;
  String? errorMessage;

  List<Notify> newNotifications = [];
  List<Notify> seenNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final fetchedNotifications =
          await _notificationService.fetchNotifications(UserSession.token!);
      final count =
          await _notificationService.getUnreadCount(UserSession.token!);

      newNotifications = fetchedNotifications
          .where((notif) => notif.readAt == null)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      seenNotifications = fetchedNotifications
          .where((notif) => notif.readAt != null)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        notifications = fetchedNotifications;
        unreadCount = count;
      });
    } catch (e, stacktrace) {
      debugPrint('Error loading notifications: $e');
      debugPrintStack(stackTrace: stacktrace);
      setState(() {
        errorMessage = 'Failed to load notifications. Please try again later.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead(UserSession.token!);
      await _loadNotifications();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      setState(() {
        errorMessage = 'Failed to mark all notifications as read.';
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return DateFormat('hh:mm a', 'es').format(date);
    } else if (difference.inDays == 1) {
      return DateFormat('Ayer, hh:mm a', 'es').format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, hh:mm a', 'es').format(date);
    } else if (date.year == now.year) {
      return DateFormat('d \'de\' MMMM', 'es').format(date);
    } else {
      return DateFormat('d \'de\' MMMM, yyyy', 'es').format(date);
    }
  }

  @override
  void dispose() {
    _markAllAsRead();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : (newNotifications.isEmpty && seenNotifications.isEmpty)
                  ? const Center(
                      child: Text(
                        'No hay notificaciones para mostrar.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView(
                      children: [
                        if (newNotifications.isNotEmpty) ...[
                          _buildSectionHeader('Nuevas'),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: newNotifications.length,
                            itemBuilder: (context, index) {
                              final notif = newNotifications[index];
                              return _buildNotificationTile(context, notif,
                                  isNew: true);
                            },
                          ),
                          if (seenNotifications.isNotEmpty)
                            const Divider(
                                height: 24,
                                thickness: 0.5,
                                indent: 16,
                                endIndent: 16),
                        ],
                        if (seenNotifications.isNotEmpty) ...[
                          _buildSectionHeader('Vistas'),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: seenNotifications.length,
                            itemBuilder: (context, index) {
                              final notif = seenNotifications[index];
                              return _buildNotificationTile(context, notif,
                                  isNew: false);
                            },
                          ),
                        ],
                      ],
                    ),
    );
  }

  // Nuevo método para los encabezados de sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, Notify notif,
      {required bool isNew}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),

        // border: Border.all(
        //   color: isNew ? Colors.blue.shade100 : Colors.grey.shade200,
        //   width: 0.8,
        // ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: () async {
            if (notif.type == 'user' && notif.user != null) {
              context.push(
                '/profile',
                extra: UserProfileView(user: notif.user!),
              );
            } else if (notif.type == 'post') {
              context.push('/post/${notif.id}');
            } else {
              debugPrint('Unhandled notification type: ${notif.type}');
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar/Imagen de notificación
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: notif.type == 'user'
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius:
                        notif.type == 'post' ? BorderRadius.circular(8) : null,
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: notif.type == 'user'
                        ? BorderRadius.circular(24)
                        : BorderRadius.circular(8),
                    child: notif.image != null
                        ? Image.network(
                            notif.type == 'user'
                                ? '${AppConfig.baseStorageUrl}/${notif.image!}'
                                : notif.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    color: Colors.grey),
                          )
                        : Image.asset(
                            'assets/posts/avatar.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight:
                              isNew ? FontWeight.w600 : FontWeight.normal,
                          color: isNew ? Colors.black87 : Colors.grey.shade800,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notif.body,
                        style: TextStyle(
                          color: isNew ? Colors.black54 : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(notif.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isNew)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Icon(Icons.circle, color: Colors.blue, size: 8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
