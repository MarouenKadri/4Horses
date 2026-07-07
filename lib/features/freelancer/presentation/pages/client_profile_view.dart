import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/presentation/pages/shared/base_profile_view.dart';
import '../../../profile/profile_provider.dart';

export '../../../profile/presentation/pages/shared/base_profile_view.dart'
    show ProfileStatData, VerifiedItemData;

// ─── Enum (partagé avec freelancer_profile_view via base) ─────────────────────

enum CancellationLevel { never, rarely, sometimes, often }

extension CancellationLevelExtension on CancellationLevel {
  String get label {
    switch (this) {
      case CancellationLevel.never:
        return "N'annule jamais";
      case CancellationLevel.rarely:
        return 'Annule rarement';
      case CancellationLevel.sometimes:
        return 'Annule parfois';
      case CancellationLevel.often:
        return 'Annule souvent';
    }
  }

  int get reliabilityScore {
    switch (this) {
      case CancellationLevel.never:
        return 100;
      case CancellationLevel.rarely:
        return 96;
      case CancellationLevel.sometimes:
        return 88;
      case CancellationLevel.often:
        return 74;
    }
  }
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class ClientProfileView extends StatefulWidget {
  final String clientName;
  final String clientAvatar;
  final double rating;
  final int reviewsCount;
  final int missionsCount;
  final String memberSince;
  final CancellationLevel cancellationLevel;
  final String level;
  final String? clientId;

  const ClientProfileView({
    super.key,
    this.clientName = 'Marie',
    this.clientAvatar = 'https://i.pravatar.cc/150?img=47',
    this.rating = 4.8,
    this.reviewsCount = 12,
    this.missionsCount = 18,
    this.memberSince = 'Mars 2023',
    this.cancellationLevel = CancellationLevel.rarely,
    this.level = 'Ambassadeur',
    this.clientId,
  });

  @override
  State<ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends BaseProfileState<ClientProfileView> {
  UserProfile? _profile;
  bool _loadingProfile = false;

  // ── Getters ─────────────────────────────────────────────────────────────────

  @override
  String get profileName => _profile?.fullName ?? widget.clientName;

  @override
  String get profileAvatar => _profile?.avatarUrl ?? widget.clientAvatar;

  @override
  double get profileRating => widget.rating;

  @override
  int get profileReviewsCount => widget.reviewsCount;

  @override
  String get profileLevel => widget.level;

  @override
  bool get isLoadingProfile => _loadingProfile;

  @override
  String? get profileUserId => widget.clientId;

  @override
  String get expectedReviewerUserType => 'freelancer';

  String get _memberStat {
    final match = RegExp(r'(20\d{2})').firstMatch(widget.memberSince);
    if (match != null) {
      final year = int.tryParse(match.group(1)!);
      if (year != null) {
        final years = DateTime.now().year - year;
        return years <= 1 ? '1 an' : '$years ans';
      }
    }
    return '2 ans';
  }

  String get _reliabilityStat =>
      '${widget.cancellationLevel.reliabilityScore}%';

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.clientId != null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    final loaded = await context.read<ProfileProvider>().fetchProfileById(
      widget.clientId!,
    );
    if (!mounted) return;
    setState(() {
      _profile = loaded;
      _loadingProfile = false;
    });
  }

  // ── BaseProfileState overrides ──────────────────────────────────────────────

  @override
  List<ProfileStatData> buildProfileStats() => [
    ProfileStatData(
      icon: Icons.calendar_today_rounded,
      value: _memberStat,
      label: 'Membre',
    ),
    ProfileStatData(
      icon: Icons.task_alt_rounded,
      value: '${widget.missionsCount}',
      label: 'Missions',
    ),
    ProfileStatData(
      icon: Icons.verified_rounded,
      value: _reliabilityStat,
      label: 'Fiabilité',
    ),
  ];

  @override
  List<VerifiedItemData> get verifiedItems => [
    const VerifiedItemData(
      label: "Pièce d'identité vérifiée",
      verified: true,
      icon: Icons.badge_outlined,
    ),
    const VerifiedItemData(
      label: 'Adresse e-mail vérifiée',
      verified: true,
      icon: Icons.alternate_email_rounded,
    ),
    const VerifiedItemData(
      label: 'Numéro de téléphone vérifié',
      verified: true,
      icon: Icons.phone_iphone_rounded,
    ),
    const VerifiedItemData(
      label: 'Moyen de paiement vérifié',
      verified: true,
      icon: Icons.credit_card_rounded,
    ),
    VerifiedItemData(
      label: widget.cancellationLevel.label,
      verified:
          widget.cancellationLevel == CancellationLevel.never ||
          widget.cancellationLevel == CancellationLevel.rarely,
      warning: widget.cancellationLevel == CancellationLevel.sometimes,
      icon: Icons.event_busy_rounded,
    ),
  ];

  @override
  Widget? buildExtraSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: 'Présentation'),
          AppGap.h8,
          Text(
            'Client actif sur la plateforme depuis ${widget.memberSince.toLowerCase()}, '
            'avec ${widget.missionsCount} missions publiées.',
            style: context.text.bodyMedium?.copyWith(
              height: 1.65,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<String?> resolveConversationId(BuildContext context) async {
    if (widget.clientId == null) return null;
    return context.read<MessagingProvider>().getOrCreateConversation(
      otherUserId: widget.clientId!,
      iAmClient: false,
    );
  }

  @override
  Widget buildChatPage(String? conversationId) => ChatPage(
    conversationId: conversationId,
    contactUserId: widget.clientId,
    contactName: profileName,
    contactAvatar: profileAvatar,
  );
}
