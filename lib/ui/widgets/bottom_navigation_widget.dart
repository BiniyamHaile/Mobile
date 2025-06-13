import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({
    super.key,
    this.child,
    required this.location,
    this.backgroundColor,
  });

  final Widget? child;
  final String location;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      backgroundColor: backgroundColor,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          key: ValueKey(location),
          currentIndex: _calculateSelectedIndex(context),
          selectedItemColor: Color.fromRGBO(143, 148, 251, 1),
          unselectedItemColor: Colors.grey[600],
          onTap: (index) => _onItemTapped(index, context),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          backgroundColor: Colors.white,
          items: [
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(Icons.home, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
            ),
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.video, size: 28),
              activeIcon: Icon(LucideIcons.video, size: 28),
            ),
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.search, size: 28),
              activeIcon: Icon(LucideIcons.search, size: 28),
            ),
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.user, size: 28),
              activeIcon: Icon(LucideIcons.user, size: 28),
            ),
            const BottomNavigationBarItem(
              label: '',
              icon: Icon(LucideIcons.wallet, size: 28),
              activeIcon: Icon(LucideIcons.wallet, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location == RouteNames.feed) {
      return 0;
    }
    if (location == RouterEnum.videoFeedView.routeName) {
      return 1;
    }
    if (location == RouteNames.search) {
      return 2;
    }
    if (location == RouterEnum.profileView.routeName) {
      return 3;
    }
    if (location == RouteNames.wallet) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go(RouteNames.feed);
        break;
      case 1:
        GoRouter.of(context).go(RouterEnum.videoFeedView.routeName);
        break;
      case 2:
        GoRouter.of(context).go(RouteNames.search);
        break;
      case 3:
        GoRouter.of(context).go(RouterEnum.profileView.routeName);
        break;
      case 4:
        GoRouter.of(context).go(RouteNames.wallet);
        break;
    }
  }
}
