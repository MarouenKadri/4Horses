import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nav components
// ─────────────────────────────────────────────────────────────────────────────

class AppNavBarSurface extends StatelessWidget {
  final Widget child;

  const AppNavBarSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset > 0 ? 10 : 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: context.colors.border),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primaryDark.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AppNavItemPill extends StatelessWidget {
  final bool selected;
  final Widget child;

  const AppNavItemPill({
    super.key,
    required this.selected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppNavMetrics.itemAnimationMs),
      curve: Curves.easeInOut,
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? context.colors.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class AppTabBarSurface extends StatelessWidget {
  final Widget child;
  final double height;

  const AppTabBarSurface({
    super.key,
    required this.child,
    this.height = AppNavMetrics.tabBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.divider, width: 1),
        ),
      ),
      child: child,
    );
  }
}

class AppSelectionIndicator extends StatelessWidget {
  final bool selected;
  final Color color;
  final double size;

  const AppSelectionIndicator({
    super.key,
    required this.selected,
    required this.color,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: Border.all(color: color, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}
