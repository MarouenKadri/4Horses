import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_design_system.dart';
import '../../features/notifications/notifications.dart';
import '../../features/profile/profile_provider.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';
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
    final isClient = widget.showRolePill
        ? context.watch<AuthProvider>().currentRole == UserRole.client
        : true;
    final avatarLabel = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';

    return AppPageAppBar(
      titleWidget: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onGoToAccount,
        child: Text(
          widget.pageTitle ?? 'Byrsa',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appBarTitleStyle,
        ),
      ),
      actions: [
        _buildBellButton(context, unreadCount),
        if (widget.showRolePill) ...[
          GestureDetector(
            onTap: () => showAppBottomSheet(
              context: context,
              wrapWithSurface: false,
              child: RoleSwitchSheet(
                firstName: firstName,
                onGoToAccount: widget.onGoToAccount,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
              decoration: BoxDecoration(
                color: context.colors.textPrimary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: avatarLabel.isNotEmpty
                        ? Text(
                            avatarLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: context.colors.background,
                              height: 1,
                            ),
                          )
                        : Icon(
                            isClient
                                ? Icons.person_outline_rounded
                                : Icons.handyman_rounded,
                            size: 14,
                            color: context.colors.background,
                          ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    isClient ? 'Client' : 'Prestataire',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                ],
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
      iconColor: context.colors.textSecondary,
      iconSize: 20,
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
