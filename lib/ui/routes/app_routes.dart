import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/ui/pages/auth/forgot-password-page.dart';
import 'package:mobile/ui/pages/auth/login_page.dart';
import 'package:mobile/ui/pages/auth/otp_page.dart';
import 'package:mobile/ui/pages/auth/preference_page.dart';
import 'package:mobile/ui/pages/auth/reset-password-page.dart';
import 'package:mobile/ui/pages/auth/signup_page.dart';
import 'package:mobile/ui/pages/chat_page.dart';
import 'package:mobile/ui/pages/notification/notifications_page.dart';
import 'package:mobile/ui/pages/post/feed_page.dart';
import 'package:mobile/ui/pages/post/post_page.dart';
import 'package:mobile/ui/pages/profile/profile-setting-page.dart';
import 'package:mobile/ui/pages/search/search_page.dart';
import 'package:mobile/ui/pages/story/user_story_page.dart';
import 'package:mobile/ui/pages/wallet_screen.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/views/reel/edit_post_screen.dart';
import 'package:mobile/ui/views/reel/profile/profile_video_player_view.dart';
import 'package:mobile/ui/views/reel/profile/profile_view.dart';
import 'package:mobile/ui/views/reel/upload/camera_screen.dart';
import 'package:mobile/ui/views/reel/upload/post_Page.dart';
import 'package:mobile/ui/views/reel/upload/video_preview_screen.dart';
import 'package:mobile/ui/views/reel/video_feed_view.dart';
import 'package:mobile/ui/widgets/bottom_navigation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRoutes {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.login,
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isAuthenticated = token != null && token.isNotEmpty;

      print(
        'Root Redirect Check: IsAuthenticated: $isAuthenticated, Target Path: ${state.uri.path}',
      );

      const unauthenticatedPaths = [
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
        RouteNames.otp,
        RouteNames.preferences,
      ];

      final isGoingToAuthenticatedPath = !unauthenticatedPaths.contains(
        state.uri.path,
      );

      final isGoingToLogin = state.uri.path == RouteNames.login;

      if (!isAuthenticated && isGoingToAuthenticatedPath) {
        print(
          'Redirecting to Login: Not authenticated and trying to access ${state.uri.path}',
        );
        return RouteNames.login;
      }

      if (isAuthenticated && isGoingToLogin) {
        print('Redirecting to Home: Authenticated and trying to access Login');
        return RouteNames.feed;
      }

      print('Allowing navigation to: ${state.uri.path}');
      return null;
    },
    
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        // Replace customPageBuilderWidget with MaterialPage
        pageBuilder: (context, state, child) => MaterialPage(
          key: state.pageKey, // Recommended to use state.pageKey
          child: BottomNavigationWidget(
            location: state.uri.toString(),
            child: child,
            backgroundColor:
                state.uri.toString() == RouterEnum.videoFeedView.routeName
                ? Colors
                      .black // Assuming 'black' is defined (e.g., Colors.black)
                : null,
          ),
        ),
        routes: [
          GoRoute(
            path: RouteNames.feed,
            // Replace customPageBuilderWidget with MaterialPage
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey, // Recommended to use state.pageKey
              child: const FeedPage(), // Assuming DashboardView is imported
            ),
          ),
          GoRoute(
            path: RouterEnum.videoFeedView.routeName,
            // Replace customPageBuilderWidget with MaterialPage
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey, // Recommended to use state.pageKey
              child:
                  const VideoFeedView(), // Assuming VideoFeedView is imported
            ),
          ),
          // Add other routes here that should be inside the shell
          GoRoute(
            path: RouteNames.search,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: SearchPage(), //
            ),
          ),
          GoRoute(
            path: RouterEnum
                .profileView
                .routeName, // Assuming you have this route
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ProfileView(), // Assuming ProfileView is imported
            ),
          ),
          GoRoute(
            path: RouteNames.wallet, // Assuming you have this route
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const WalletScreen(), // Assuming WalletScreen is imported
            ),
          ),
        ],
      ),

      GoRoute(
        path: RouteNames.profileSetting,
        builder: (context, state) => SettingsPage(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => NotificationsPage(),
      ),
      GoRoute(
        path: RouteNames.preferences,
        builder: (context, state) => const PreferencesPage(),
      ),
      // GoRoute(
      //   path: RouteNames.home,
      //   builder: (context, state) => const HomePage(),
      // ),
      // GoRoute(
      //   path: RouteNames.feed,
      //   builder: (context, state) => const FeedPage(),
      // ),
      GoRoute(
        path: RouteNames.post,
        builder: (context, state) => PostingScreen(),
      ),
      GoRoute(
        path: RouteNames.stories,
        builder: (context, state) {
          final index = state.uri.queryParameters['index'];
          return UserStoryPage(initialIndex: int.parse(index ?? '0'));
        },
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => ProfileView(),
      ),
      // GoRoute(
      //   path: RouteNames.wallet,
      //   builder: (context, state) => WalletScreen(),
      // ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) => const OtpPage(),
      ),
      GoRoute(
        path: RouteNames.preferences,
        builder: (context, state) => const PreferencesPage(),
      ),
      // GoRoute(
      //   path: RouteNames.login,
      //   builder: (context, state) => const LoginPage(),
      // ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();

          final token = prefs.getString('token');

          print(
            'Checking auth token in redirect. Token found: ${token != null && token.isNotEmpty}',
          );

          if (token != null && token.isNotEmpty) {
            return RouteNames.feed;
          }

          return null;
        },
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(path: RouteNames.chat, builder: (context, state) => ChatPage()),
      // GoRoute(
      //   path: RouterEnum.videoFeedView.routeName,
      //   builder: (context, state) => const VideoFeedView(),
      // ),
      GoRoute(
        path: RouterEnum.cameraScreen.routeName,
        builder: (context, state) => const CameraScreen(),
      ),
      // GoRoute(
      //   path: RouterEnum.profileView.routeName,
      //   builder: (context, state) => const ProfileView(),
      // ),
      GoRoute(
        path: RouterEnum.videoPreviewScreen.routeName,
        pageBuilder: (context, state) {
          final videoPath = state.pathParameters['videoPath'];
          print("Navigating to VideoPreviewScreen : $videoPath");

          if (videoPath == null) {
            return const MaterialPage(
              key: ValueKey('video_preview_error_page'),
              child: Scaffold(
                body: Center(
                  child: Text('Error: Video path missing for preview'),
                ),
              ),
            );
          }

          return MaterialPage(
            key: state.pageKey,
            child: VideoPreviewScreen(videoPath: videoPath),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.postScreen.routeName,
        pageBuilder: (context, state) {
          final videoPath = state.pathParameters['videoPath'];
          if (videoPath == null) {
            return const MaterialPage(
              child: Scaffold(
                body: Center(
                  child: Text('Error: Video path missing for posting'),
                ),
              ),
            );
          }

          return MaterialPage(
            key: state.pageKey,
            child: PostScreen(videoPath: videoPath),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.profileVideoPlayerView.routeName,
        pageBuilder: (context, state) {
          final args = state.extra;

          if (args is Map<String, dynamic>) {
            final userVideos = args['userVideos'];
            final initialIndex = args['initialIndex'];

            if (userVideos is List<VideoItem> && initialIndex is int) {
              return MaterialPage(
                key: state.pageKey,
                child: ProfileVideoPlayerView(
                  userVideos: userVideos,
                  initialIndex: initialIndex,
                ),
              );
            }
          }

          return const MaterialPage(
            child: Scaffold(
              body: Center(
                child: Text('Error: Missing or invalid video data.'),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.editPostScreen.routeName,
        pageBuilder: (context, state) {
          final initialData = state.extra;

          if (initialData is Map<String, dynamic>) {
            try {
              final String videoUrl = initialData['videoUrl'] as String;
              final String initialDescription =
                  initialData['initialDescription'] as String;

              final PrivacyOption initialPrivacy =
                  initialData['initialPrivacy'] as PrivacyOption;
              final bool initialAllowComments =
                  initialData['initialAllowComments'] as bool;
              final bool initialSaveToDevice =
                  initialData['initialSaveToDevice'] as bool;
              final bool initialSaveWithWatermark =
                  initialData['initialSaveWithWatermark'] as bool;
              final bool initialAudienceControls =
                  initialData['initialAudienceControls'] as bool;

              final reelId = initialData['reelId'] as String;
              print("reel $reelId");

              return MaterialPage(
                key: state.pageKey,
                child: EditPostScreen(
                  reelId: reelId,
                  videoUrl: videoUrl,
                  initialDescription: initialDescription,
                  initialPrivacy: initialPrivacy,
                  initialAllowComments: initialAllowComments,
                  initialSaveToDevice: initialSaveToDevice,
                  initialSaveWithWatermark: initialSaveWithWatermark,
                  initialAudienceControls: initialAudienceControls,
                ),
              );
            } catch (e) {
              print("Error processing initial data for EditPostScreen: $e");
              return const MaterialPage(
                child: Scaffold(
                  body: Center(
                    child: Text('Error: Invalid initial post data.'),
                  ),
                ),
              );
            }
          }

          return const MaterialPage(
            child: Scaffold(
              body: Center(child: Text('Error: Missing initial post data.')),
            ),
          );
        },
      ),
    ],
  );
}
