import 'package:flutter/material.dart';

typedef AppNavPagesBuilder = List<Widget> Function(ValueChanged<int> goToIndex);
typedef AppNavFabBuilder = Widget? Function(
  BuildContext context,
  int currentIndex,
  bool fabExpanded,
  ValueChanged<bool> setFabExpanded,
  ValueChanged<int> goToIndex,
);

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem(this.icon, this.activeIcon, this.label);
}

class AppNavConfig {
  final List<NavItem> items;
  final AppNavPagesBuilder pagesBuilder;
  final AppNavFabBuilder? fabBuilder;
  final bool trackScrollForFab;

  const AppNavConfig({
    required this.items,
    required this.pagesBuilder,
    this.fabBuilder,
    this.trackScrollForFab = false,
  });
}
