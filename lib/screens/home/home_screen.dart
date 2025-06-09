import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/screens/views/explorer_view.dart';
import 'package:new_application_api/screens/views/home_view.dart';
import 'package:new_application_api/screens/views/bookmarks_view.dart';
import 'package:new_application_api/screens/views/user_profile_view.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:new_application_api/config.dart';

class HomeScreen extends StatefulWidget {
  final int? initialTab;
  final Widget? customBody;

  const HomeScreen({
    super.key,
    this.initialTab,
    this.customBody,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Widget? customBody;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const ExplorerView(),
    const BookmarksView(),
    UserProfileView(user: UserSession.currentUser!, itsMe: true),
  ];

  void showCustomView(Widget? view) {
    setState(() {
      customBody = view;
    });
  }

  ImageProvider _getProfileImage() {
    final baseUrl = AppConfig.baseStorageUrl;
    final profileImage = UserSession.currentUser?.profileImage;
    if (profileImage != null && profileImage.isNotEmpty) {
      return NetworkImage('$baseUrl/$profileImage');
    }
    return const AssetImage('assets/posts/avatar.png');
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab ?? 0;
    customBody = widget.customBody;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final image = _getProfileImage();
    if (image is NetworkImage) {
      precacheImage(image, context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      customBody = null;
      if (index == 2) {
        context.push('/create-post');
      } else {
        _selectedIndex = index > 2 ? index - 1 : index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: customBody ??
              IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              _selectedIndex < 2 ? _selectedIndex : _selectedIndex + 1,
          onTap: _onItemTapped,
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
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1
                    ? PhosphorIcons.magnifyingGlassFill
                    : PhosphorIcons.magnifyingGlass,
                size: 26,
                color: Colors.black,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                PhosphorIcons.plusCircle,
                size: 28,
                color: Colors.black,
              ),
              activeIcon: Icon(
                PhosphorIcons.plusCircleFill,
                size: 28,
                color: Colors.black,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 2
                    ? PhosphorIcons.bookBookmarkFill
                    : PhosphorIcons.bookBookmark,
                size: 26,
                color: Colors.black,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedIndex == 3
                        ? Colors.black
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: FadeInImage(
                    placeholder: const AssetImage('assets/posts/avatar.png'),
                    image: _getProfileImage(),
                    fit: BoxFit.cover,
                    width: 24,
                    height: 24,
                    fadeInDuration: const Duration(milliseconds: 200),
                    imageErrorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/posts/avatar.png',
                            fit: BoxFit.cover),
                  ),
                ),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
