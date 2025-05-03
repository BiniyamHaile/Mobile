import 'package:go_router/go_router.dart';
import 'package:mobile/ui/pages/auth/signup_page.dart';
import 'package:mobile/ui/pages/chat_page.dart';
import 'package:mobile/ui/pages/post/feed_page.dart';
import 'package:mobile/ui/pages/home_page.dart';
import 'package:mobile/ui/pages/post/post_page.dart';
import 'package:mobile/ui/pages/profile_page.dart';
import 'package:mobile/ui/pages/story/user_story_page.dart';
import 'package:mobile/ui/routes/route_names.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
    GoRoute(path: RouteNames.home, builder: (context, state) => const HomePage()
    ),
    GoRoute(path: RouteNames.feed, builder: (context, state) => const FeedPage()
    ),
    GoRoute(path: RouteNames.post, builder: (context, state) => PostingScreen()
    ),
    GoRoute(path: RouteNames.stories, builder: (context, state) {
      final index = state.uri.queryParameters['index'];
      return UserStoryPage(initialIndex:  int.parse(index ?? '0'));
    }
    ),
    GoRoute(path: RouteNames.profile, builder: (context, state) => ProfilePage(),
    ),
    GoRoute(path: RouteNames.register, builder: (context, state) => SignupPage()),
    GoRoute(path: RouteNames.chat, builder: (context, state) => ChatPage())
  ]);
}
