import 'package:flutter/material.dart';
import 'package:new_application_api/screens/auth/login_screen.dart';
import 'package:new_application_api/screens/views/create_post_view.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/services/auth/auth_service.dart';
import 'package:new_application_api/screens/views/profile_view.dart';
import 'package:new_application_api/screens/views/search_view.dart';
import 'package:new_application_api/screens/views/home_view.dart';
import 'package:new_application_api/screens/views/bookmarks_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final user = UserSession.currentUser;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const SearchView(),
    const CreatePostView(),
    const BookmarksView(),
    const ProfileView(),
  ];

  void _logout() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await AuthService().logout(UserSession.token!);

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      if (response.success) {
        UserSession.clearSession();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        SnackBar(
          content: Text(response.message),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      SnackBar(
        content: Text("Error logging out"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          title: Text(
            'Bloogol',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => _logout(),
              icon: Icon(PhosphorIcons.bell, color: Colors.black, size: 22),
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          elevation: 15,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 0
                      ? PhosphorIcons.houseFill
                      : PhosphorIcons.house,
                  size: 26,
                  color: Colors.black,
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 1
                      ? PhosphorIcons.magnifyingGlassFill
                      : PhosphorIcons.magnifyingGlass,
                  size: 26,
                  color: Colors.black,
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 2
                      ? PhosphorIcons.plusCircleFill
                      : PhosphorIcons.plusCircle,
                  size: 28,
                  color: Colors.black,
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 3
                      ? PhosphorIcons.bookBookmarkFill
                      : PhosphorIcons.bookBookmark,
                  size: 26,
                  color: Colors.black,
                ),
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 4
                      ? PhosphorIcons.userFill
                      : PhosphorIcons.user,
                  size: 26,
                  color: Colors.black,
                ),
                label: ''),
          ],
        ),
      ),
    );
  }
}
