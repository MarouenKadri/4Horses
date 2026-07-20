import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../../../app/auth_provider.dart';
import '../../../../app/enum/user_role.dart';
import '../../data/models/message.dart';
import '../../messaging_provider.dart';
import 'chat_page.dart';
import '../../../../app/app_bar/app_section_bar.dart';
import '../../../client/presentation/pages/freelancer_profile_view.dart';
import '../../../freelancer/presentation/pages/client_profile_view.dart';

class MessagesPage extends StatefulWidget {
  final VoidCallback? onGoToAccount;
  const MessagesPage({super.key, this.onGoToAccount});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  UserRole? _lastRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isClient =
          context.read<AuthProvider>().currentRole == UserRole.client;
      _lastRole = isClient ? UserRole.client : UserRole.provider;
      context.read<MessagingProvider>().loadConversations(
        isClientMode: isClient,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final role = Provider.of<AuthProvider>(context).currentRole;
    if (role != _lastRole && _lastRole != null) {
      _lastRole = role;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<MessagingProvider>().loadConversations(
          forceRefresh: true,
          isClientMode: role == UserRole.client,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppSectionBar(
        pageTitle: 'Messages',
        onGoToAccount: widget.onGoToAccount,
      ),
      body: AppPageBody(
        child: Consumer<MessagingProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingConversations) {
              return const Center(
                child: AppLoadingIndicator(size: 28, strokeWidth: 2.6),
              );
            }

            if (provider.conversationError != null) {
              return AppEmptyStateBlock(
                icon: Icons.wifi_off_rounded,
                title: 'Messages indisponibles',
                message: provider.conversationError,
                action: AppButton(
                  label: 'Réessayer',
                  icon: Icons.refresh_rounded,
                  variant: ButtonVariant.secondary,
                  onPressed: () =>
                      provider.loadConversations(forceRefresh: true),
                ),
              );
            }

            if (provider.conversations.isEmpty) {
              return const AppEmptyStateBlock(
                icon: Icons.forum_rounded,
                title: 'Aucune conversation',
                message:
                    'Vos échanges avec vos clients et prestataires apparaîtront ici.',
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadConversations(forceRefresh: true),
              color: AppColors.primary,
              child: ListView.separated(
                padding: AppInsets.v8,
                itemCount: provider.conversations.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: context.colors.divider,
                ),
                itemBuilder: (context, i) => _ConversationTile(
                  conversation: provider.conversations[i],
                  currentUserId: provider.currentUserId ?? '',
                  isClientMode:
                      context.read<AuthProvider>().currentRole ==
                      UserRole.client,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final bool isClientMode;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.isClientMode,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final avatar =
        conversation.otherUserAvatar ??
        'https://api.dicebear.com/7.x/avataaars/png?seed=${conversation.otherUserId}';
    final isOtherFreelancer = currentUserId == conversation.clientId;

    void goToProfile() {
      if (isOtherFreelancer) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FreelancerProfileView(
              freelancerId: conversation.otherUserId,
              freelancerName: conversation.otherUserName,
              freelancerAvatar: avatar,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientProfileView(
              clientId: conversation.otherUserId,
              clientName: conversation.otherUserName,
              clientAvatar: avatar,
            ),
          ),
        );
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: conversation.id,
              contactUserId: conversation.otherUserId,
              contactName: conversation.otherUserName,
              contactAvatar: avatar,
              isVerified: conversation.isOtherVerified,
              missionTitle: conversation.missionTitle,
              missionId: conversation.missionId,
              showReserveButton: conversation.missionId == null && isClientMode,
              freelancerId: conversation.missionId == null && isClientMode
                  ? conversation.otherUserId
                  : null,
              confirmedMissionTitle: conversation.missionTitle,
              onProfileTap: goToProfile,
            ),
          ),
        ).then((_) {
          if (context.mounted) {
            context.read<MessagingProvider>().loadConversations(
              forceRefresh: true,
            );
          }
        });
      },
      child: Padding(
        padding: AppInsets.h16v12,
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              onBackgroundImageError: avatar.isNotEmpty ? (_, __) {} : null,
              child: avatar.isEmpty
                  ? const Icon(Icons.person_rounded, size: 28)
                  : null,
            ),
            AppGap.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: _nameStyle(context, hasUnread),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: _metaStyle(context, hasUnread),
                        ),
                    ],
                  ),
                  AppGap.h4,
                  Row(
                    children: [
                      if (conversation.missionTitle != null) ...[
                        AppTagPill(
                          label: conversation.missionTitle!,
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          fontSize: AppFontSize.xs,
                          fontWeight: FontWeight.w600,
                        ),
                        AppGap.w6,
                      ],
                      Expanded(
                        child: Text(
                          _formatLastMessage(conversation.lastMessage),
                          style: _messageStyle(context, hasUnread),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread)
                        AppCountBadge(
                          label: '${conversation.unreadCount}',
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastMessage(String? raw) {
    if (raw == null) return 'Démarrez la conversation';
    if (raw.startsWith('📍 ')) return '📍 Position partagée';
    return raw;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 6) return '${time.day}/${time.month}';
    if (diff.inDays >= 1) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[time.weekday - 1];
    }
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  TextStyle? _nameStyle(BuildContext context, bool hasUnread) =>
      context.text.titleMedium?.copyWith(
        fontSize: AppFontSize.lg,
        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
        color: context.colors.textPrimary,
      );

  TextStyle? _metaStyle(BuildContext context, bool hasUnread) =>
      context.text.labelMedium?.copyWith(
        fontSize: AppFontSize.sm,
        color: hasUnread ? AppColors.primary : context.colors.textTertiary,
        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
      );

  TextStyle? _messageStyle(BuildContext context, bool hasUnread) =>
      context.text.bodyMedium?.copyWith(
        fontSize: AppFontSize.base,
        color: hasUnread
            ? context.colors.textPrimary
            : context.colors.textSecondary,
        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
      );
}
