import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../data/models/app_notification.dart';
import '../../notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _showUnreadOnly = false;

  /// Tap sur une notification : marque lue, et si elle porte un payload
  /// actionnable (demande de contact), ouvre directement le chat.
  Future<void> _handleTap(
    BuildContext context,
    AppNotification notification,
  ) async {
    context.read<NotificationProvider>().markRead(notification.id);

    final data = notification.data;
    if (data == null || data['kind'] != 'contact_request') return;
    final freelancerId = data['freelancer_id'] as String?;
    if (freelancerId == null) return;

    final conversationId = await context
        .read<MessagingProvider>()
        .getOrCreateConversation(otherUserId: freelancerId, iAmClient: true);
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: conversationId,
          contactUserId: freelancerId,
          contactName: data['freelancer_name'] as String? ?? 'Prestataire',
          contactAvatar: notification.avatarUrl ?? '',
          isVerified: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    final unreadCount = provider.unreadCount;
    final filtered = _showUnreadOnly
        ? notifications.where((notification) => !notification.isRead).toList()
        : notifications;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 0),
              child: Row(
                children: [
                  AppBackButtonLeading(
                    size: 18,
                    color: context.colors.textSecondary,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: context.text.displayMedium?.copyWith(
                        fontSize: AppFontSize.h1Lg,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    AppButton(
                      label: 'Tout lire',
                      onPressed: () =>
                          context.read<NotificationProvider>().markAllRead(),
                      variant: ButtonVariant.ghost,
                      width: null,
                      height: 36,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Toutes',
                    selected: !_showUnreadOnly,
                    onTap: () => setState(() => _showUnreadOnly = false),
                  ),
                  const SizedBox(width: 10),
                  _FilterPill(
                    label: unreadCount > 0
                        ? 'Non lues ($unreadCount)'
                        : 'Non lues',
                    selected: _showUnreadOnly,
                    onTap: () => setState(() => _showUnreadOnly = true),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyNotifications(showUnreadOnly: _showUnreadOnly)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notification = filtered[index];
                        return Dismissible(
                          key: ValueKey(notification.id),
                          direction: DismissDirection.endToStart,
                          background: const _DismissBackground(),
                          onDismissed: (_) {
                            context
                                .read<NotificationProvider>()
                                .deleteNotification(notification.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                          child: _NotificationCard(
                            notification: notification,
                            onTap: () => _handleTap(context, notification),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: AppSurfaceCard(
          padding: AppInsets.a16,
          borderRadius: radius,
          border: Border.all(color: context.colors.border),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationAvatar(notification: notification),
              AppGap.w14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: context.text.titleSmall?.copyWith(
                              fontSize: AppFontSize.body,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          AppGap.w10,
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: context.colors.textPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppGap.h6,
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        fontSize: AppFontSize.mdHalf,
                        height: 1.45,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    AppGap.h8,
                    Text(
                      notification.timeAgo,
                      style: context.text.labelMedium?.copyWith(
                        fontSize: AppFontSize.sm,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationAvatar extends StatelessWidget {
  final AppNotification notification;

  const _NotificationAvatar({required this.notification});

  @override
  Widget build(BuildContext context) {
    if (notification.avatarUrl != null && notification.avatarUrl!.isNotEmpty) {
      return Container(
        width: 50,
        height: 50,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.border, width: 1),
        ),
        child: Image.network(
          notification.avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _AvatarFallback(type: notification.type),
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.border, width: 1),
      ),
      child: Center(
        child: Icon(
          _typeIcon(notification.type),
          size: 20,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }

  static IconData _typeIcon(NotifType type) {
    switch (type) {
      case NotifType.message:
        return Icons.chat_bubble_outline_rounded;
      case NotifType.mission:
        return Icons.work_outline_rounded;
      case NotifType.candidature:
        return Icons.person_outline_rounded;
      case NotifType.payment:
        return Icons.account_balance_wallet_outlined;
      case NotifType.review:
        return Icons.star_outline_rounded;
    }
  }
}

class _AvatarFallback extends StatelessWidget {
  final NotifType type;

  const _AvatarFallback({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case NotifType.message:
        icon = Icons.chat_bubble_outline_rounded;
        break;
      case NotifType.mission:
        icon = Icons.work_outline_rounded;
        break;
      case NotifType.candidature:
        icon = Icons.person_outline_rounded;
        break;
      case NotifType.payment:
        icon = Icons.account_balance_wallet_outlined;
        break;
      case NotifType.review:
        icon = Icons.star_outline_rounded;
        break;
    }

    return Container(
      color: context.colors.surfaceAlt,
      child: Center(
        child: Icon(icon, size: 20, color: context.colors.textSecondary),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: AppInsets.h16v10,
        decoration: BoxDecoration(
          color: selected
              ? context.colors.textPrimary
              : context.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: context.text.labelLarge?.copyWith(
            fontSize: AppFontSize.md,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.errorLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Icon(
        Icons.delete_outline_rounded,
        color: context.colors.error,
        size: 20,
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final bool showUnreadOnly;

  const _EmptyNotifications({required this.showUnreadOnly});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              showUnreadOnly
                  ? 'Aucune notification non lue'
                  : 'Aucune notification',
              textAlign: TextAlign.center,
              style: context.text.titleLarge?.copyWith(
                fontSize: AppFontSize.title,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tout est a jour pour le moment.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(
                fontSize: AppFontSize.md,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
