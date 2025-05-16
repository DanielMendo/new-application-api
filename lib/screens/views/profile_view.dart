import 'package:flutter/material.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/models/user.dart';

class ProfileView extends StatelessWidget {
  final User? user;

  const ProfileView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return UserProfileView(
      user: user ?? UserSession.currentUser!,
      itsMe: user != null ? false : true,
    );
  }
}
