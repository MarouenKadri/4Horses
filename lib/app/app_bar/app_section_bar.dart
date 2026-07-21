import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_design_system.dart';
import '../../features/notifications/notifications.dart';
import '../../features/profile/profile_provider.dart';
import 'role_switch_sheet.dart';

/// App bar standard des pages de section.
/// - Sans [pageTitle] : affiche une pill de marque
/// - Avec [pageTitle] : affiche un titre de section avec accent
/// Accepte un [bottom] optionnel pour les pages avec TabBar.
class AppSectionBar extends StatefulWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final String? pageTitle;
  final VoidCallback? onGoToAccount;
  final bool showRolePill;

  const AppSectionBar({
    super.key,
    this.bottom,
    this.pageTitle,
    this.onGoToAccount,
    this.showRolePill = false,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  State<AppSectionBar> createState() => _AppSectionBarState();
}

class _AppSectionBarState extends State<AppSectionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellController;
  late final Animation<double> _bellScale;
  int _previousUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppBarMetrics.bellAnimationMs),
    );
    _bellScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bellController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  void _triggerBellAnimation(int newCount) {
    if (newCount > _previousUnreadCount) {
      _bellController.forward(from: 0);
    }
    _previousUnreadCount = newCount;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    _triggerBellAnimation(unreadCount);
    final profile = context.watch<ProfileProvider>().profile;
    final firstName = profile?.firstName ?? '';

    return AppPageAppBar(
      titleWidget: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onGoToAccount,
        child: Text(
          widget.pageTitle ?? '4horses',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appBarTitleStyle,
        ),
      ),
      actions: [
        _buildBellButton(context, unreadCount),
        if (widget.showRolePill) ...[
          const SizedBox(width: 8),
          AppBarActionCircleButton(
            icon: Icons.sync_alt_rounded,
            backgroundColor: Colors.transparent,
            iconColor: AppColors.primary,
            border: Border.all(color: AppColors.primary, width: 1.5),
            iconSize: 18,
            size: 34,
            onTap: () => showAppBottomSheet(
              context: context,
              wrapWithSurface: false,
              child: RoleSwitchSheet(
                firstName: firstName,
                onGoToAccount: widget.onGoToAccount,
              ),
            ),
          ),
        ],
        const SizedBox(width: 12),
      ],
      bottom: widget.bottom,
    );
  }

  Widget _buildBellButton(BuildContext context, int unreadCount) {
    return AppBarActionCircleButton(
      icon: Icons.notifications_none_rounded,
      backgroundColor: Colors.transparent,
      iconColor: context.colors.textPrimary,
      iconSize: 23,
      size: 34,
      scale: _bellScale,
      badgeLabel: unreadCount > 0
          ? (unreadCount > 99 ? '99+' : '$unreadCount')
          : null,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsPage()),
      ),
      badgeColor: AppColors.error,
    );
  }
}
