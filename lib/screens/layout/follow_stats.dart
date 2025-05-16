// import 'package:flutter/material.dart';
// import 'package:new_application_api/services/user_service.dart';
// import 'package:new_application_api/utils/user_session.dart';

// class FollowStatsWidget extends StatefulWidget {
//   final int userId;
//   final bool itsMe;

//   const FollowStatsWidget(
//       {super.key, required this.userId, required this.itsMe});

//   @override
//   State<FollowStatsWidget> createState() => _FollowStatsWidgetState();
// }

// class _FollowStatsWidgetState extends State<FollowStatsWidget> {
//   late Future<Map<String, dynamic>> _followStats;

//   @override
//   void initState() {
//     super.initState();
//     _followStats = _loadStats();
//   }

//   Future<Map<String, dynamic>> _loadStats() {
//     return UserService().fetchFollowStats(widget.userId, UserSession.token!);
//   }

//   void _toggleFollow(bool currentlyFollowing) async {
//     if (currentlyFollowing) {
//       await UserService().unfollow(widget.userId, UserSession.token!);
//     } else {
//       await UserService().follow(widget.userId, UserSession.token!);
//     }

//     setState(() {
//       _followStats = _loadStats();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _followStats,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const SizedBox.shrink(); // o spinner si quieres
//         }

//         final data = snapshot.data!;
//         final followers = data['followers_count'];
//         final following = data['following_count'];
//         final isFollowing = data['is_following'];

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text('$followers Seguidores',
//                     style: const TextStyle(fontSize: 15)),
//                 const SizedBox(width: 20),
//                 Text('$following Siguiendo',
//                     style: const TextStyle(fontSize: 15)),
//               ],
//             ),
//             const SizedBox(height: 10),
//             if (!widget.itsMe)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isFollowing
//                         ? Colors.red.shade900
//                         : Theme.of(context).primaryColor,
//                   ),
//                   onPressed: () => _toggleFollow(isFollowing),
//                   child: Text(
//                     isFollowing ? 'Dejar de seguir' : 'Seguir',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               )
//           ],
//         );
//       },
//     );
//   }
// }
