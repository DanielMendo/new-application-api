import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_application_api/models/category.dart';
import 'package:new_application_api/models/post.dart';
import 'package:new_application_api/screens/auth/email_sent_screen.dart';
import 'package:new_application_api/screens/auth/forgot_screen.dart';
import 'package:new_application_api/screens/auth/signup_screen.dart';
import 'package:new_application_api/screens/home/home_screen.dart';
import 'package:new_application_api/screens/posts/comments_screen.dart';
import 'package:new_application_api/screens/posts/post_view.dart';
import 'package:new_application_api/screens/auth/login_screen.dart';
import 'package:new_application_api/screens/views/all_categories.dart';
import 'package:new_application_api/screens/views/category_posts_view.dart';
import 'package:new_application_api/screens/views/create_post_view.dart';
import 'package:new_application_api/screens/views/edit_post_view.dart';
import 'package:new_application_api/screens/views/edit_profile.dart';
import 'package:new_application_api/screens/views/follower_following.dart';
import 'package:new_application_api/screens/views/notifications_view.dart';
import 'package:new_application_api/screens/views/post_image_viewer.dart';
import 'package:new_application_api/screens/views/preview_post.view.dart';
import 'package:new_application_api/screens/views/search_view.dart';
import 'package:new_application_api/screens/views/select_categories.dart';
import 'package:new_application_api/screens/views/select_privacy.dart';
import 'package:new_application_api/screens/views/settings/change_email.dart';
import 'package:new_application_api/screens/views/settings/change_password.dart';
import 'package:new_application_api/screens/views/settings/delete_account.dart';
import 'package:new_application_api/screens/views/unsplash_view.dart';
import 'package:new_application_api/screens/views/user_settings_view.dart';
import 'package:new_application_api/utils/user_session.dart';
import 'package:new_application_api/widgets/profile_image.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    await UserSession.loadSession();

    final loggedIn = UserSession.isLoggedIn();
    final currentPath = state.fullPath;

    const publicRoutes = [
      '/login',
      '/register',
      '/forgot-password',
      '/email-sent'
    ];

    if (!loggedIn && !publicRoutes.contains(currentPath)) {
      return '/login';
    }

    if (loggedIn && publicRoutes.contains(currentPath)) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotScreen(),
    ),
    GoRoute(
      path: '/email-sent',
      builder: (context, state) => const EmailSent(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsView(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final customBody = state.extra as Widget?;
        return HomeScreen(customBody: customBody);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
        path: '/profile-image',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final imageUrl = extra['imageUrl'] as String;
          return ProfileImageView(imageUrl: imageUrl);
        }),
    GoRoute(
        path: '/followers-following',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final userId = extra['userId'] as int;
          final showFollowers = extra['showFollowers'] as bool;

          return FollowersFollowingView(
            userId: userId,
            showFollowers: showFollowers,
          );
        }),
    GoRoute(
      path: '/user-settings',
      builder: (context, state) => const UserSettingsView(),
    ),
    GoRoute(
      path: '/change-email',
      builder: (context, state) => const ChangeEmailScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/delete-account',
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: '/create-post',
      builder: (context, state) => const CreatePostView(),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PostDetailScreen(postId: id);
      },
    ),
    GoRoute(
      path: '/preview-post',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return PreviewPostView(
          isEditing: data['isEditing'] as bool?,
          postId: data['postId'] as int?,
          title: data['title'],
          description: data['description'],
          initialImageUrl: data['image'] as String?,
          allImages: data['allImages'] as List<String>,
          html: data['html'],
          privacy: data['privacy'] as bool?,
          initialSelectedCategory: data['category'] as Category?,
        );
      },
    ),
    GoRoute(
      path: '/edit-post',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final post = extra['post'] as Post;
        final category = extra['category'] as Category;

        return EditPostView(post: post, selectedCategory: category);
      },
    ),
    GoRoute(
      path: '/unsplash-search',
      builder: (context, state) => const UnsplashSearchPage(),
    ),
    GoRoute(
        path: '/all-categories',
        builder: (context, state) => const AllCategoriesView()),
    GoRoute(
      path: '/comments/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CommentsScreen(postId: int.parse(id));
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchView(),
    ),
    GoRoute(
      path: '/select-category',
      builder: (context, state) {
        final selectedCategory = state.extra as Category?;
        return SelectCategoriesView(selectedCategory);
      },
    ),
    GoRoute(
        path: '/category-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final categoryId = extra['categoryId'] as int;
          final categoryName = extra['categoryName'] as String;
          final categoryDescription = extra['categoryDescription'] as String;

          return CategoryDetailScreen(
            categoryId: categoryId,
            categoryName: categoryName,
            categoryDescription: categoryDescription,
          );
        }),
    GoRoute(
      path: '/select-privacy',
      builder: (context, state) {
        final privacy = state.extra as bool?;
        return SelectPrivacyView(privacy);
      },
    ),
    GoRoute(
      path: '/image-viewer',
      builder: (context, state) {
        final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
        return ImageViewerScreen(
          imageUrls: args['imageUrls'] as List<String>,
          initialSelectedImage: args['initialSelectedImage'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/',
      redirect: (_, __) => '/home',
    ),
  ],
);
