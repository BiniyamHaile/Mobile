import 'package:flutter/material.dart';
import 'package:mobile/common/common.dart';
import 'package:mobile/ui/pages/post/feed_page.dart';
import 'package:mobile/ui/pages/pages.dart';
import 'package:mobile/ui/pages/post/reels_page.dart';

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
      children: [
        const FeedPage(),
        const NotificationsPage(),
        ProfilePage(),
        ReelsPage()
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
                NavigationRailDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: Icon(
            Icons.photo_camera,
            color: theme.colorScheme.primary,
          ),
          label: const Text('Reels'),
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
                   NavigationDestination(
          icon:  const Icon(Icons.person_outlined),
          selectedIcon: Icon(
            Icons.photo_camera,
            color: theme.colorScheme.primary,
          ),
          label:'Reels',
        ),
      ],
    );
  }
}
