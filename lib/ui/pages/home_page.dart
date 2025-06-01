import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/common/common.dart';
import 'package:mobile/ui/pages/pages.dart';
import 'package:mobile/ui/pages/post/feed_page.dart';
import 'package:mobile/ui/views/reel/profile/profile_view.dart';
import 'package:mobile/ui/views/reel/video_feed_view.dart';


const String channelId = 'aladia_notifications';
const String channelName = 'Aladia Alerts';
const String channelDescription =
    'Stay informed with the latest updates, news, and alerts from Aladia.';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  late PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
@override
void initState() {
  super.initState();
  initNotifications().then((_) {
    flutterLocalNotificationsPlugin.show(
      22,
      'title',
      'body',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  });
}


final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true, // You can handle foreground manually if needed
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}



  @override
  Widget build(BuildContext context) {
    final pageView = _buildPageView();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: context.responsive(
        sm: pageView,
        md: Row(
          children: [
            _navigationRail(context),
            const VerticalDivider(width: 1, thickness: 1),
            Flexible(child: pageView),
          ],
        ),
      ),
      bottomNavigationBar: context.isMobile ? _navigationBar(context) : null,
    );
  }

  void _pageChanged(int value) {
    if (_pageIndex == value && _pageController.hasClients) return;
    setState(() => _pageIndex = value);
    _pageController.jumpToPage(value);
  }

  Widget _buildPageView() {
    _pageController = PageController(initialPage: _pageIndex);

    return PageView(
      controller: _pageController,
      onPageChanged: _pageChanged,
      children: const [
        FeedPage(),
        VideoFeedView(),
        NotificationsPage(),
        ProfileView(),
      ],
    );
  }

  /// tablet & desktop screen
  NavigationRail _navigationRail(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return NavigationRail(
      selectedIndex: _pageIndex,
      onDestinationSelected: _pageChanged,
      extended: context.isDesktop,
      labelType: context.isDesktop
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      selectedLabelTextStyle: textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: textTheme.bodyMedium,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home,
            color: theme.colorScheme.primary,
          ),
          label: const Text('Home'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.videocam),
          selectedIcon: Icon(
            Icons.photo_camera,
            color: theme.colorScheme.primary,
          ),
          label: const Text('Reels'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: Icon(
            Icons.notifications,
            color: theme.colorScheme.primary,
          ),
          label: const Text('Notifications'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: Icon(
            Icons.person,
            color: theme.colorScheme.primary,
          ),
          label: const Text('Profile'),
        ),
      ],
    );
  }

  /// mobile screen
  NavigationBar _navigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: _pageIndex,
      height: 65,
      onDestinationSelected: _pageChanged,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home,
            color: theme.colorScheme.primary,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.videocam),
          selectedIcon: Icon(
            Icons.photo_camera,
            color: theme.colorScheme.primary,
          ),
          label: 'Reels',
        ),
        NavigationDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: Icon(
            Icons.notifications,
            color: theme.colorScheme.primary,
          ),
          label: 'Notifications',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: Icon(
            Icons.person,
            color: theme.colorScheme.primary,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
