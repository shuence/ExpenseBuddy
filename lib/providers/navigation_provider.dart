import 'package:flutter/cupertino.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Navigation items
  static const List<NavigationItem> navigationItems = [
    NavigationItem(
      index: 0,
      title: 'Home',
      icon: CupertinoIcons.home,
      activeIcon: CupertinoIcons.house_fill,
      route: '/home',
    ),
    NavigationItem(
      index: 1,
      title: 'Transactions',
      icon: CupertinoIcons.list_bullet,
      activeIcon: CupertinoIcons.list_bullet_below_rectangle,
      route: '/transactions',
    ),
    NavigationItem(
      index: 2,
      title: 'Add',
      icon: CupertinoIcons.add_circled,
      activeIcon: CupertinoIcons.add_circled_solid,
      route: '/add-transaction',
      isCenter: true,
    ),
    NavigationItem(
      index: 3,
      title: 'Budget',
      icon: CupertinoIcons.chart_pie,
      activeIcon: CupertinoIcons.chart_pie_fill,
      route: '/budget',
    ),
    NavigationItem(
      index: 4,
      title: 'Profile',
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      route: '/profile',
    ),
  ];
}

class NavigationItem {
  final int index;
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final bool isCenter;

  const NavigationItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.isCenter = false,
  });
}
