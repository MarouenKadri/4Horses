import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design/app_design_system.dart';
import '../auth_provider.dart';
import '../enum/user_role.dart';
import '../../features/messaging/messaging_provider.dart';
import '../../features/messaging/presentation/pages/messages_page.dart';
import '../../features/mission/presentation/pages/client/create_mission_page.dart';
import '../../features/notifications/notification_provider.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/shared/account_page.dart';
import 'bottom_nav/app_nav_config.dart';
import 'bottom_nav/app_nav_shell.dart';
import 'shell/discover_shell.dart';
import 'shell/missions_shell.dart';

/// Navigation principale unifiée — un seul arbre pour les deux rôles.
/// Les onglets Découvrir et Missions délèguent le contenu
/// à leurs shells rôle-aware respectifs.
class AppNav extends StatelessWidget {
  const AppNav({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentRole;
    final isClient = role == UserRole.client;
    const accountIndex = 4;

    return Consumer<MessagingProvider>(
      builder: (_, messaging, __) => Consumer<NotificationProvider>(
        builder: (_, notif, __) => AppNavShell(
          // ValueKey(role) force la réinitialisation des pages au changement de rôle.
          key: ValueKey(role),
          config: AppNavConfig(
            items: [
              NavItem(
                isClient ? Icons.home_outlined : Icons.search_outlined,
                isClient ? Icons.home_rounded : Icons.search_rounded,
                isClient ? 'Découvrir' : 'Explorer',
              ),
              NavItem(
                isClient ? Icons.assignment_outlined : Icons.work_outline_rounded,
                isClient ? Icons.assignment_rounded : Icons.work_rounded,
                'Missions',
              ),
              NavItem(
                Icons.chat_bubble_outline,
                Icons.chat_bubble_rounded,
                'Messages',
              ),
              NavItem(
                Icons.notifications_outlined,
                Icons.notifications_rounded,
                'Notifications',
              ),
              NavItem(
                Icons.person_outline_rounded,
                Icons.person_rounded,
                isClient ? 'Compte' : 'Profil',
              ),
            ],
            pagesBuilder: (goToIndex) => [
              DiscoverShell(
                onGoToAccount: () => goToIndex(accountIndex),
                onGoToMissions: () => goToIndex(1),
              ),
              MissionsShell(onGoToAccount: () => goToIndex(accountIndex)),
              MessagesPage(onGoToAccount: () => goToIndex(accountIndex)),
              const NotificationsPage(),
              const AccountPage(),
            ],
            fabBuilder: isClient
                ? (context, _, __, ___, ____) => _CreateMissionNavButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PostMissionFlow()),
                      ),
                    )
                : null,
          ),
          badgeCounts: {2: messaging.totalUnread, 3: notif.unreadCount},
        ),
      ),
    );
  }
}

class _CreateMissionNavButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateMissionNavButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Publier une mission',
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.inkDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Publier',
                style: TextStyle(
                  fontSize: AppFontSize.tinyHalf,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
