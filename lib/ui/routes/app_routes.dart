import 'package:go_router/go_router.dart';
import 'package:mobile/ui/pages/feed_page.dart';
import 'package:mobile/ui/pages/home_page.dart';
import 'package:mobile/ui/pages/post_page.dart';
import 'package:mobile/ui/pages/profile_page.dart';
import 'package:mobile/ui/pages/user_story_page.dart';
import 'package:mobile/ui/routes/route_names.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: "/home",
    routes: [
    GoRoute(path: "/home", builder: (context, state) => const HomePage()
    ),
    GoRoute(path: "/feed", builder: (context, state) => const FeedPage()
    ),
    GoRoute(path: "/post", builder: (context, state) => PostingScreen()
    ),
    GoRoute(path: RouteNames.stories, builder: (context, state) {
      final index = state.uri.queryParameters['index'];
      return UserStoryPage(initialIndex:  int.parse(index ?? '0'));
    }
    ),
    GoRoute(path: RouteNames.profile, builder: (context, state) => ProfilePage()
    ),
  ]);
}