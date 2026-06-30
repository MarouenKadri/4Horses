import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_design_system.dart';
import '../../features/notifications/notification_provider.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import 'location_search_page.dart';
import 'role_switch_sheet.dart';

export 'location_search_page.dart' show LocationType;
export 'role_switch_sheet.dart' show RoleSwitchSheet;

// ─── Data model ───────────────────────────────────────────────────────────────

class LocationData {
  final IconData icon;
  final String label;
  final String subtitle;

  const LocationData({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
}

// ─── Dumb presentation bar ────────────────────────────────────────────────────

class HomeActionBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final int unreadCount;

  final VoidCallback onNotificationsTap;
  final Animation<double>? bellScale;

  const HomeActionBar({
    super.key,
    this.bottom,
    required this.unreadCount,
    required this.onNotificationsTap,
    this.bellScale,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        AppBarMetrics.toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppPageAppBar(
      toolbarHeight: AppBarMetrics.toolbarHeight,
      bottom: bottom,
      actions: [
        AppBarActionCircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
          size: 34,
          iconSize: 20,
          backgroundColor: Colors.transparent,
          iconColor: context.colors.textSecondary,
          badgeLabel: unreadCount > 0
              ? (unreadCount > 99 ? '99+' : '$unreadCount')
              : null,
          badgeColor: AppColors.error,
          scale: bellScale,
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

// ─── Static helpers ───────────────────────────────────────────────────────────

class HomeAppBarCoordinator {
  const HomeAppBarCoordinator._();

  static Future<LocationData?> pickLocation(
    BuildContext context, {
    required String? currentAddress,
    LocationData? selectedLocation,
  }) {
    final current = selectedLocation?.label ?? parseCity(currentAddress);
    final initType =
        selectedLocation?.icon == Icons.location_on_rounded ||
                selectedLocation?.icon == Icons.location_city_rounded
            ? LocationType.other
            : LocationType.current;
    final previousOther =
        initType == LocationType.other ? selectedLocation?.label : null;

    return Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationSearchPage(
          currentCity: current,
          initialType: initType,
          initialOtherAddress: previousOther,
        ),
      ),
    );
  }

  static Future<void> openNotifications(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  static Future<void> openRoleSheet(
    BuildContext context, {
    required String firstName,
    String avatarUrl = '',
    VoidCallback? onGoToAccount,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      wrapWithSurface: false,
      child: RoleSwitchSheet(
        firstName: firstName,
        avatarUrl: avatarUrl,
        onGoToAccount: onGoToAccount,
      ),
    );
  }

  static String parseCity(String? address) {
    if (address == null || address.trim().isEmpty) return 'Ma position';
    final parts = address.split(',');
    final city = parts.last.trim();
    return city.isEmpty ? address.trim() : city;
  }
}

// ─── Stateful widget ─────────────────────────────────────────────────────────

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final VoidCallback? onGoToAccount;

  const HomeAppBar({super.key, this.bottom, this.onGoToAccount});

  @override
  Size get preferredSize => Size.fromHeight(
        AppBarMetrics.toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellCtrl;
  late final Animation<double> _bellScale;
  int _prevUnread = 0;

  @override
  void initState() {
    super.initState();
    _bellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppBarMetrics.bellAnimationMs),
    );
    _bellScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bellCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    if (unread > _prevUnread) _bellCtrl.forward(from: 0);
    _prevUnread = unread;

    return HomeActionBar(
      bottom: widget.bottom,
      unreadCount: unread,
      bellScale: _bellScale,
      onNotificationsTap: () =>
          HomeAppBarCoordinator.openNotifications(context),
    );
  }
}
