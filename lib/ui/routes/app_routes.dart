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
import 'package:mobile/ui/pages/home_page.dart';
import 'package:mobile/ui/pages/post/feed_page.dart';
import 'package:mobile/ui/pages/post/post_page.dart';
import 'package:mobile/ui/pages/profile/profile-setting-page.dart';
import 'package:mobile/ui/pages/profile_page.dart';
import 'package:mobile/ui/pages/story/user_story_page.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/views/reel/edit_post_screen.dart';
import 'package:mobile/ui/views/reel/profile/profile_video_player_view.dart';
import 'package:mobile/ui/views/reel/profile/profile_view.dart';
import 'package:mobile/ui/views/reel/upload/camera_screen.dart';
import 'package:mobile/ui/views/reel/upload/post_Page.dart';
import 'package:mobile/ui/views/reel/upload/video_preview_screen.dart';
import 'package:mobile/ui/views/reel/video_feed_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: RouteNames.preferences,
    // Add the root-level redirect function here
    redirect: (context, state) async {
      // This redirect runs before ANY route is matched or navigated to.
      // It's the perfect place to check auth state on startup or when
      // a new route is requested.

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isAuthenticated = token != null && token.isNotEmpty;

      print(
        'Root Redirect Check: IsAuthenticated: $isAuthenticated, Target Path: ${state.uri.path}',
      );

      // Define the paths that are accessible *without* authentication
      const unauthenticatedPaths = [
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
        RouteNames.otp, // Assuming OTP is part of the signup flow
        RouteNames
            .preferences, // Assuming preferences is part of the signup flow
        // Add any other public pages here (e.g., a landing page)
      ];

      // Check if the user is trying to navigate to a path that requires authentication
      final isGoingToAuthenticatedPath = !unauthenticatedPaths.contains(
        state.uri.path,
      );

      // Check if the user is explicitly trying to go to the login page
      final isGoingToLogin = state.uri.path == RouteNames.login;

      // --- Redirection Logic ---

      // 1. If the user is NOT authenticated AND they are trying to access
      //    a page that requires authentication, redirect them to the login page.
      if (!isAuthenticated && isGoingToAuthenticatedPath) {
        print(
          'Redirecting to Login: Not authenticated and trying to access ${state.uri.path}',
        );
        return RouteNames.login;
      }

      // 2. If the user IS authenticated AND they are trying to access the login page,
      //    redirect them to the home page. (Prevents logged-in users from seeing login).
      if (isAuthenticated && isGoingToLogin) {
        print('Redirecting to Home: Authenticated and trying to access Login');
        return RouteNames.home;
      }

      // 3. Otherwise, allow the navigation to the requested path.
      //    This covers:
      //    - Authenticated users going to authenticated paths (home, profile, feed, etc.)
      //    - Unauthenticated users going to unauthenticated paths (login, register, forgot password, etc.)
      print('Allowing navigation to: ${state.uri.path}');
      return null; // Return null to allow navigation to the original path
    },
    routes: [
      GoRoute(path: RouteNames.profileSetting, builder: (context, state) =>  SettingsPage()),
      GoRoute(path: RouteNames.preferences, builder: (context, state) => const PreferencesPage()),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.feed,
        builder: (context, state) => const FeedPage(),
      ),
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
        builder: (context, state) => ProfilePage(),
      ),
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
        // --- ADD THE REDIRECT LOGIC HERE ---
        redirect: (context, state) async {
          // This redirect runs *before* navigating to the login page.

          // Get the SharedPreferences instance (asynchronous)
          final prefs = await SharedPreferences.getInstance();

          // Read the authentication token using your defined key
          final token = prefs.getString('token');

          print(
            'Checking auth token in redirect. Token found: ${token != null && token.isNotEmpty}',
          );

          // If a token is found (not null and not empty), redirect to the home route.
          if (token != null && token.isNotEmpty) {
            // Return the path you want to redirect to
            return RouteNames.home; // Or your defined home route name
          }

          return null;
        },
        // ------------------------------------
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
      GoRoute(
        path: RouterEnum.videoFeedView.routeName,
        builder: (context, state) => const VideoFeedView(),
      ),
      GoRoute(
        path: RouterEnum.cameraScreen.routeName,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: RouterEnum.profileView.routeName,
        builder: (context, state) => const ProfileView(),
      ),
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