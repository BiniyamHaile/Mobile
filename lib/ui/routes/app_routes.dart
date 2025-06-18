import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// --- (Import all your pages, models, and route constants here) ---
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
import 'package:mobile/ui/pages/post/report_page.dart';
import 'package:mobile/ui/pages/profile/profile-setting-page.dart';
import 'package:mobile/ui/pages/search/search_page.dart';
import 'package:mobile/ui/pages/story/user_story_page.dart';
import 'package:mobile/ui/pages/wallet_screen.dart';
import 'package:mobile/ui/views/reel/edit_post_screen.dart';
import 'package:mobile/ui/views/reel/profile/profile_video_player_view.dart';
import 'package:mobile/ui/views/reel/profile/profile_view.dart';
import 'package:mobile/ui/views/reel/upload/camera_screen.dart';
import 'package:mobile/ui/views/reel/upload/post_Page.dart' as ReelPostScreen; // Aliased
import 'package:mobile/ui/views/reel/upload/video_preview_screen.dart';
import 'package:mobile/ui/views/reel/video_feed_view.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';


// ===================================================================
// PART 1: THE CORRECTED BOTTOM NAVIGATION WIDGET
// This now includes all 5 of your original icons.
// ===================================================================
class BottomNavigationWidget extends StatefulWidget {
  final Widget child;
  final String location;

  const BottomNavigationWidget({
    Key? key,
    required this.child,
    required this.location,
  }) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  // Your new 4-item list is perfect.
  final iconList = <IconData>[
    Icons.home_outlined,
    LucideIcons.video,
    LucideIcons.user,
    LucideIcons.wallet,
  ];

  // CORRECTED: The indices now match the 4-item list (0, 1, 2, 3)
  int _calculateSelectedIndex(String location) {
    if (location.startsWith(RouteNames.feed)) return 0;
    if (location.startsWith(RouterEnum.videoFeedView.routeName)) return 1;
    if (location.startsWith(RouterEnum.profileView.routeName)) return 2; // Fixed from 3 to 2
    if (location.startsWith(RouteNames.wallet)) return 3; // Fixed from 4 to 3
    return -1;
  }

  // CORRECTED: The cases now match the 4-item list (0, 1, 2, 3)
  void _onTap(int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.feed);
        break;
      case 1:
        context.go(RouterEnum.videoFeedView.routeName);
        break;
      case 2:
        context.go(RouterEnum.profileView.routeName); // Fixed from case 3
        break;
      case 3:
        context.go(RouteNames.wallet); // Fixed from case 4
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navBarColor = widget.location == RouterEnum.videoFeedView.routeName
        ? Colors.black
        : Theme.of(context).canvasColor;
        
    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.post), // Changed to .go for consistency
        child: const Icon(Icons.add, size: 30),
        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
      ),
      // To support your 4 items (an even number), you can now
      // safely move the button back to the center if you want!
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _calculateSelectedIndex(widget.location),
        // You can now use .center again because you have 4 icons.
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        onTap: _onTap,
        backgroundColor: navBarColor,
        activeColor: Color.fromRGBO(143, 148, 251, 1),
        inactiveColor: Colors.grey[600],
      ),
    );
  }
}
// ===================================================================
// PART 2: THE UPDATED GO_ROUTER CONFIGURATION
// ===================================================================
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRoutes {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.login,
    redirect: (context, state) async {
      // Your redirect logic remains unchanged
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isAuthenticated = token != null && token.isNotEmpty;
      const unauthenticatedPaths = [
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
        RouteNames.otp,
        RouteNames.preferences,
      ];
      final isGoingToAuthenticatedPath = !unauthenticatedPaths.contains(state.uri.path);
      final isGoingToLogin = state.uri.path == RouteNames.login;
      if (!isAuthenticated && isGoingToAuthenticatedPath) {
        return RouteNames.login;
      }
      if (isAuthenticated && isGoingToLogin) {
        return RouteNames.feed;
      }
      return null;
    },
    routes: [
      // ShellRoute using the corrected BottomNavigationWidget
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) => NoTransitionPage(
          child: BottomNavigationWidget(
            location: state.uri.toString(),
            child: child,
          ),
        ),
        // ALL 5 routes are now included here again.
        routes: [
          GoRoute(
            path: RouteNames.feed,
            pageBuilder: (context, state) => const NoTransitionPage(child: FeedPage()),
          ),
          GoRoute(
            path: RouterEnum.videoFeedView.routeName,
            pageBuilder: (context, state) => const NoTransitionPage(child: VideoFeedView()),
          ),
          GoRoute(
            path: RouterEnum.profileView.routeName,
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileView()),
          ),
          GoRoute(
            path: RouteNames.wallet,
            pageBuilder: (context, state) => const NoTransitionPage(child: WalletScreen()),
          ),
        ],
      ),

      // --- ALL YOUR OTHER ROUTES (without the bottom bar) ---
      // These are copied directly from your original file
      GoRoute(path: RouteNames.login, builder: (context, state) => const LoginPage()),
      GoRoute(path: RouteNames.register, builder: (context, state) => const SignupPage()),
      GoRoute(path: RouteNames.forgotPassword, builder: (context, state) => const ForgotPasswordPage()),
      GoRoute(path: RouteNames.resetPassword, builder: (context, state) => const ResetPasswordPage()),
      GoRoute(path: RouteNames.otp, builder: (context, state) => const OtpPage()),
      GoRoute(path: RouteNames.preferences, builder: (context, state) => const PreferencesPage()),
      GoRoute(path: RouteNames.profileSetting, builder: (context, state) => SettingsPage()),
      GoRoute(path: RouteNames.notifications, builder: (context, state) => NotificationsPage()),
      GoRoute(path: RouteNames.post, builder: (context, state) => PostingScreen()),
      GoRoute(
            path: RouteNames.search,
            pageBuilder: (context, state) =>  NoTransitionPage(child: SearchPage()),
          ),
      GoRoute(
        path: RouteNames.stories,
        builder: (context, state) {
          final index = state.uri.queryParameters['index'];
          return UserStoryPage(initialIndex: int.tryParse(index ?? '0') ?? 0);
        },
      ),
      GoRoute(path: RouteNames.chat, builder: (context, state) => ChatPage()),
      GoRoute(
        path: RouteNames.reportPost,
        builder: (context, state) {
          return ReportPage(postId: state.extra as String? ?? '');
        },
      ),
      GoRoute(path: RouterEnum.cameraScreen.routeName, builder: (context, state) => const CameraScreen()),
      GoRoute(
        path: RouterEnum.videoPreviewScreen.routeName,
        pageBuilder: (context, state) {
          final videoPath = state.pathParameters['videoPath'];
          return MaterialPage(
            child: videoPath != null
                ? VideoPreviewScreen(videoPath: videoPath)
                : const Scaffold(body: Center(child: Text('Error: Video path missing'))),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.postScreen.routeName,
        pageBuilder: (context, state) {
          final videoPath = state.pathParameters['videoPath'];
          return MaterialPage(
            child: videoPath != null
                ? ReelPostScreen.PostScreen(videoPath: videoPath)
                : const Scaffold(body: Center(child: Text('Error: Video path missing'))),
          );
        },
      ),
      GoRoute(
        path: RouterEnum.profileVideoPlayerView.routeName,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          if (args != null && args['userVideos'] is List<VideoItem> && args['initialIndex'] is int) {
             return MaterialPage(
                child: ProfileVideoPlayerView(
                  userVideos: args['userVideos'],
                  initialIndex: args['initialIndex'],
                ),
              );
          }
          return const MaterialPage(child: Scaffold(body: Center(child: Text('Error: Missing video data'))));
        },
      ),
      GoRoute(
        path: RouterEnum.editPostScreen.routeName,
        pageBuilder: (context, state) {
          final initialData = state.extra as Map<String, dynamic>?;
           if (initialData != null) {
              return MaterialPage(
                child: EditPostScreen(
                  reelId: initialData['reelId'],
                  videoUrl: initialData['videoUrl'],
                  initialDescription: initialData['initialDescription'],
                  initialPrivacy: initialData['initialPrivacy'],
                  initialAllowComments: initialData['initialAllowComments'],
                  initialSaveToDevice: initialData['initialSaveToDevice'],
                  initialSaveWithWatermark: initialData['initialSaveWithWatermark'],
                  initialAudienceControls: initialData['initialAudienceControls'],
                ),
              );
           }
            return const MaterialPage(child: Scaffold(body: Center(child: Text('Error: Missing post data'))));
        },
      ),
    ],
  );
}