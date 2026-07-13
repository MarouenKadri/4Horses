import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/design/app_design_system.dart';
import '../../data/models/message.dart';
import '../../messaging_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../../../mission/presentation/mission_provider.dart';
import '../../../mission/presentation/pages/client/create_mission_page.dart';
import '../../../mission/presentation/pages/client/client_mission_detail_page.dart';
import '../../../mission/presentation/widgets/shared/mission_shared_widgets.dart';


class ChatPage extends StatefulWidget {
  final String? conversationId;
  final String? contactUserId;
  final String contactName;
  final String contactAvatar;
  final bool isOnline;
  final bool isVerified;
  final String? missionTitle;

  final bool candidateMode;
  final String? candidatePrice;
  final VoidCallback? onAcceptCandidate;

  final bool showReserveButton;
  final String? freelancerId;
  final String? freelancerAvatarUrl;

  final String? confirmedMissionTitle;
  final VoidCallback? onProfileTap;

  /// When true, content moderation is lifted so participants can share
  /// phone numbers and addresses for on-site coordination.
  final bool isMissionConfirmed;

  const ChatPage({
    super.key,
    this.conversationId,
    this.contactUserId,
    required this.contactName,
    required this.contactAvatar,
    this.isOnline = false,
    this.isVerified = false,
    this.missionTitle,
    this.candidateMode = false,
    this.candidatePrice,
    this.onAcceptCandidate,
    this.showReserveButton = false,
    this.freelancerId,
    this.freelancerAvatarUrl,
    this.confirmedMissionTitle,
    this.onProfileTap,
    this.isMissionConfirmed = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatProvider _chatProvider;
  final _scrollController = ScrollController();

  bool _candidateAccepted = false;
  String? _bookedMissionTitle;
  bool _showContactWarning = false;
  int _prevMessageCount = 0;
  double _scrollExtentBeforeLoadMore = 0;

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider(
      onConversationSync: context
          .read<MessagingProvider>()
          .updateConversationPreview,
    );
    _chatProvider.setMissionConfirmed(widget.isMissionConfirmed);
    _chatProvider.addListener(_onChatUpdated);
    if (widget.conversationId != null) {
      _chatProvider.open(widget.conversationId!);
    }
  }

  void _onChatUpdated() {
    final count = _chatProvider.messages.length;
    if (count <= _prevMessageCount) return;

    if (_chatProvider.lastUpdateWasPrepend) {
      // Restore scroll position after prepend so the view doesn't jump
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final added =
            _scrollController.position.maxScrollExtent -
            _scrollExtentBeforeLoadMore;
        if (added > 0) {
          _scrollController.jumpTo(_scrollController.position.pixels + added);
        }
      });
    } else {
      _scrollToBottom();
    }
    _prevMessageCount = count;
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onChatUpdated);
    if (widget.conversationId != null) _chatProvider.close();
    _chatProvider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openReservation() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PostMissionFlow(
          preAssignedFreelancerId: widget.freelancerId,
          preAssignedFreelancerName: widget.contactName,
          preAssignedFreelancerAvatar:
              widget.freelancerAvatarUrl ?? widget.contactAvatar,
        ),
      ),
    );
    if (result == null || !result.startsWith('published:') || !mounted) return;

    // format: 'published:<missionId>:<title>'
    final payload = result.substring('published:'.length);
    final sep = payload.indexOf(':');
    final missionId = sep > 0 ? payload.substring(0, sep) : '';
    final title = (sep > 0 ? payload.substring(sep + 1) : payload).trim();
    final displayTitle = title.isNotEmpty ? title : 'Mission réservée';

    // Link conversation → mission (updates badge + hides reserve button)
    if (missionId.isNotEmpty && widget.conversationId != null) {
      context.read<MessagingProvider>().linkConversationToMission(
        widget.conversationId!,
        missionId,
        displayTitle,
      );
    }

    setState(() => _bookedMissionTitle = displayTitle);

    // Navigate to mission detail page so the client can continue the flow there.
    if (missionId.isEmpty || !mounted) return;
    final missions = context.read<MissionProvider>().clientMissions;
    final idx = missions.indexWhere((m) => m.id == missionId);
    if (idx != -1 && mounted) {
      Navigator.push(
        context,
        slideUpRoute(page: ClientMissionDetailPage(mission: missions[idx])),
      );
    }
  }

  void _acceptCandidateFromChat() {
    showAppDialog(
      context: context,
      title: const Text('Accepter ce prestataire ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: context.text.bodyMedium?.copyWith(color: context.colors.textSecondary),
              children: [
                const TextSpan(text: 'Vous allez accepter '),
                TextSpan(
                  text: widget.contactName,
                  style: context.chatBannerStyle.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.candidatePrice != null) ...[
                  const TextSpan(text: ' pour '),
                  TextSpan(
                    text: widget.candidatePrice,
                    style: context.chatBannerStyle.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const TextSpan(text: '.'),
              ],
            ),
          ),
          AppGap.h12,
          Container(
            padding: AppInsets.a12,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.warning,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Les autres candidats seront automatiquement refusés.',
                    style: context.chatBannerStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Confirmer',
      onConfirm: () {
        Navigator.pop(context);
        setState(() => _candidateAccepted = true);
        widget.onAcceptCandidate?.call();
      },
    );
  }

  void _showChatOptions() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: AppActionSheet(
        title: widget.contactName,
        dark: false,
        children: [
          if (widget.onProfileTap != null)
            AppActionSheetItem(
              icon: Icons.person_outline_rounded,
              title: 'Voir le profil',
              dark: false,
              onTap: () {
                Navigator.pop(context);
                widget.onProfileTap!();
              },
            ),
          if (widget.missionTitle != null)
            AppActionSheetItem(
              icon: Icons.assignment_outlined,
              title: 'Voir la mission',
              subtitle: widget.missionTitle,
              dark: false,
              onTap: () => Navigator.pop(context),
            ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          AppActionSheetItem(
            icon: Icons.flag_outlined,
            title: 'Signaler',
            dark: false,
            destructive: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeMissionTitle =
        _bookedMissionTitle ?? widget.confirmedMissionTitle;
    final showReserve =
        widget.showReserveButton &&
        _bookedMissionTitle == null &&
        widget.confirmedMissionTitle == null;

    return ChangeNotifierProvider.value(
      value: _chatProvider,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: context.colors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            if (activeMissionTitle != null)
              _ConfirmedMissionBadge(title: activeMissionTitle),
            if (widget.missionTitle != null)
              _MissionBanner(
                missionTitle: widget.missionTitle!,
                contactName: widget.contactName,
                showAccept: widget.candidateMode && !_candidateAccepted,
                candidatePrice: widget.candidatePrice,
                candidateAccepted: _candidateAccepted,
                onAccept: _acceptCandidateFromChat,
              ),
            if (_showContactWarning)
              _ContactWarning(
                onDismiss: () => setState(() => _showContactWarning = false),
              ),
            Expanded(
              child: _MessageList(
                conversationId: widget.conversationId,
                contactUserId: widget.contactUserId,
                contactAvatar: widget.contactAvatar,
                scrollController: _scrollController,
                onLoadMoreTriggered: () {
                  _scrollExtentBeforeLoadMore = _scrollController.hasClients
                      ? _scrollController.position.maxScrollExtent
                      : 0;
                },
              ),
            ),
            ChatInputBar(
              onSendMessage: _chatProvider.sendMessage,
              onSendSuccess: _scrollToBottom,
              onModerationWarning: (blocked) =>
                  setState(() => _showContactWarning = blocked),
              contactName: widget.contactName,
              contactAvatar: widget.contactAvatar,
              activeMissionTitle: activeMissionTitle,
              showReserveButton: showReserve,
              onReserveTap: _openReservation,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 0.5, color: context.colors.divider),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: context.colors.textPrimary,
          size: 18,
        ),
        onPressed: () => Navigator.pop(context, _candidateAccepted),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: widget.onProfileTap,
            child: CircleAvatar(
              radius: 19,
              backgroundImage: NetworkImage(widget.contactAvatar),
              backgroundColor: context.colors.divider,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.contactName,
                        style: context.chatTitleStyle.copyWith(color: context.colors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isVerified) ...[
                      AppGap.w4,
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: context.colors.textPrimary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  widget.isOnline ? 'En ligne' : 'Vu récemment',
                  style: context.chatMetaStyle.copyWith(color: context.colors.textHint),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_horiz_rounded,
            color: context.colors.textPrimary,
            size: 22,
          ),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }
}

// ─── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final String? conversationId;
  final String? contactUserId;
  final String contactAvatar;
  final ScrollController scrollController;

  /// Called just before loadMore is triggered, so the parent can capture
  /// the current maxScrollExtent for scroll-position preservation.
  final VoidCallback onLoadMoreTriggered;

  const _MessageList({
    required this.conversationId,
    required this.contactUserId,
    required this.contactAvatar,
    required this.scrollController,
    required this.onLoadMoreTriggered,
  });

  @override
  Widget build(BuildContext context) {
    if (conversationId == null) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: const AppEmptyStateBlock(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Démarrez la conversation',
          message:
              'Envoyez un premier message pour préciser votre besoin ou poser une question.',
        ),
      );
    }

    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        // ── Erreur réseau ─────────────────────────────────────────────────
        if (provider.error != null) {
          return AppEmptyStateBlock(
            icon: Icons.wifi_off_rounded,
            title: 'Conversation indisponible',
            message: provider.error!,
            action: AppButton(
              label: 'Réessayer',
              icon: Icons.refresh_rounded,
              variant: ButtonVariant.black,
              onPressed: () =>
                  provider.open(conversationId!, forceRefresh: true),
            ),
          );
        }

        final messages = provider.messages;
        final currentUserId = provider.currentUserId ?? '';

        bool isMyMessage(ChatMessage msg) {
          if (currentUserId.isNotEmpty) return msg.senderId == currentUserId;
          if (contactUserId != null) return msg.senderId != contactUserId;
          return false;
        }

        if (messages.isEmpty) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: const AppEmptyStateBlock(
              icon: Icons.forum_outlined,
              title: 'Aucun message',
              message:
                  'La conversation commencera dès que vous enverrez votre premier message.',
            ),
          );
        }

        // ── Liste avec pagination ─────────────────────────────────────────
        final hasLoadingHeader = provider.isLoadingMore;
        final itemCount = (hasLoadingHeader ? 1 : 0) + messages.length;

        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notif) {
              if (notif.metrics.pixels <= 100 &&
                  provider.hasMore &&
                  !provider.isLoadingMore &&
                  !provider.isLoading) {
                onLoadMoreTriggered();
                provider.loadMore();
              }
              return false;
            },
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                // Spinner en haut pendant le chargement des anciens messages
                if (hasLoadingHeader && index == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  );
                }

                final msgIndex = hasLoadingHeader ? index - 1 : index;
                final msg = messages[msgIndex];
                final isMe = isMyMessage(msg);
                final showAvatar =
                    !isMe &&
                    (msgIndex == 0 || isMyMessage(messages[msgIndex - 1]));
                return ChatMessageBubble(
                  message: msg,
                  isMe: isMe,
                  showAvatar: showAvatar,
                  contactAvatar: contactAvatar,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─── Local widgets ────────────────────────────────────────────────────────────

class _ConfirmedMissionBadge extends StatelessWidget {
  final String title;
  const _ConfirmedMissionBadge({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      color: context.colors.textPrimary,
      child: Row(
        children: [
          const Icon(Icons.task_alt_rounded, size: 13, color: Colors.white70),
          AppGap.w6,
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionBanner extends StatelessWidget {
  final String missionTitle;
  final String contactName;
  final bool showAccept;
  final String? candidatePrice;
  final bool candidateAccepted;
  final VoidCallback onAccept;

  const _MissionBanner({
    required this.missionTitle,
    required this.contactName,
    required this.showAccept,
    this.candidatePrice,
    required this.candidateAccepted,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      missionTitle,
      if (candidatePrice != null)
        candidateAccepted
            ? '✓ Prestataire choisi • $candidatePrice'
            : candidatePrice!,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              parts.join(' • '),
              style: context.chatBannerStyle.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showAccept) ...[
            AppGap.w12,
            GestureDetector(
              onTap: onAccept,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.colors.textPrimary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Accepter',
                  style: context.chatPrimaryActionStyle.copyWith(
                    fontSize: AppFontSize.sm,
                    color: context.colors.surface,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactWarning extends StatelessWidget {
  final VoidCallback onDismiss;
  const _ContactWarning({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: AppInsets.h16v12,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
          AppGap.w10,
          Expanded(
            child: Text(
              'Le partage de coordonnées personnelles n\'est pas autorisé.',
              style: context.chatWarningStyle,
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, color: AppColors.error, size: 16),
          ),
        ],
      ),
    );
  }
}
