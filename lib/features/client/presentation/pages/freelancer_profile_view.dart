import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../mission/data/models/service_category.dart';
import '../../../mission/presentation/pages/client/create_mission_page.dart';
import '../../../profile/presentation/pages/shared/base_profile_view.dart';
import '../../../story/story.dart';
import '../providers/freelancer_public_profile_provider.dart';

export '../../../profile/presentation/pages/shared/base_profile_view.dart'
    show ProfileStatData, VerifiedItemData;

// ─── Enums ────────────────────────────────────────────────────────────────────

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

enum FreelancerContactMode { spontaneous, pendingCandidate, confirmedPresta }

// ─── Widget ───────────────────────────────────────────────────────────────────

class FreelancerProfileView extends StatefulWidget {
  final String freelancerName;
  final String freelancerAvatar;
  final double hourlyRate;
  final String experienceLevel;
  final double rating;
  final int reviewsCount;
  final int missionsCount;
  final String memberSince;
  final CancellationLevel cancellationLevel;
  final String? proposedPrice;
  final String? responseTime;
  final String? freelancerId;
  final FreelancerContactMode contactMode;
  final VoidCallback? onCandidateAccepted;
  final String? candidatePrice;
  final String? confirmedMissionTitle;

  const FreelancerProfileView({
    super.key,
    this.freelancerName = 'Thomas',
    this.freelancerAvatar = 'https://i.pravatar.cc/150?img=3',
    this.hourlyRate = 25,
    this.experienceLevel = 'Ambassadeur',
    this.rating = 5.0,
    this.reviewsCount = 40,
    this.missionsCount = 142,
    this.memberSince = 'Janvier 2022',
    this.cancellationLevel = CancellationLevel.rarely,
    this.proposedPrice,
    this.responseTime,
    this.freelancerId,
    this.contactMode = FreelancerContactMode.spontaneous,
    this.onCandidateAccepted,
    this.candidatePrice,
    this.confirmedMissionTitle,
  });

  @override
  State<FreelancerProfileView> createState() => _FreelancerProfilePageState();
}

class _FreelancerProfilePageState
    extends BaseProfileState<FreelancerProfileView> {
  late final FreelancerPublicProfileProvider _profileProvider;

  // ── Getters DB ──────────────────────────────────────────────────────────────

  @override
  String get profileName =>
      _profileProvider.profile?.fullName ?? widget.freelancerName;

  @override
  String get profileAvatar =>
      _profileProvider.profile?.avatarUrl ?? widget.freelancerAvatar;

  @override
  double get profileRating => _profileProvider.profile?.rating ?? widget.rating;

  @override
  int get profileReviewsCount =>
      _profileProvider.profile?.reviewsCount ?? widget.reviewsCount;

  @override
  String get profileLevel => widget.experienceLevel;

  @override
  bool get isLoadingProfile => _profileProvider.isLoading;

  @override
  String? get profileUserId => widget.freelancerId;

  @override
  String get expectedReviewerUserType => 'client';

  @override
  bool get showPublicationsTab => widget.freelancerId != null;

  /// Métier(s) sous le nom, façon @handle TikTok.
  @override
  String get profileSubtitle {
    final names = ServiceCategory.resolveNames(
      _profileProvider.profile?.serviceCategories ?? const <String>[],
    );
    return names.take(2).join(' · ');
  }

  @override
  String get profileBio => _bio;

  @override
  Widget? buildAvatarBadge(BuildContext context) {
    if (_profileProvider.profile?.isVerified != true) return null;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.background,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.verified_rounded,
        size: 22,
        color: AppColors.info,
      ),
    );
  }

  @override
  Widget buildPublicationsContent(BuildContext context) =>
      _FreelancerPublicationsContent(freelancerId: widget.freelancerId!);

  int get _missionsCount =>
      _profileProvider.profile?.missionsCount ?? widget.missionsCount;

  String get _bio => _profileProvider.profile?.bio ?? '';
  String get _address => _profileProvider.profile?.address ?? '';
  double? get _latitude => _profileProvider.profile?.latitude;
  double? get _longitude => _profileProvider.profile?.longitude;
  double get _zoneRadius => _profileProvider.profile?.zoneRadius ?? 10;
  double get _rate => _profileProvider.profile?.hourlyRate ?? widget.hourlyRate;

  String get _experienceStat {
    final createdAt = _profileProvider.profile?.createdAt;
    if (createdAt != null) {
      final years = DateTime.now().difference(createdAt).inDays ~/ 365;
      return years <= 1 ? '1 an' : '$years ans';
    }
    final match = RegExp(r'(20\d{2})').firstMatch(widget.memberSince);
    if (match == null) return '2 ans';
    final year = int.tryParse(match.group(1)!);
    if (year == null) return '2 ans';
    final years = DateTime.now().year - year;
    return years <= 1 ? '1 an' : '$years ans';
  }


  CancellationLevel get _cancellationLevel {
    final rate = _profileProvider.profile?.cancellationRate;
    if (rate == null) return widget.cancellationLevel;
    if (rate <= 0) return CancellationLevel.never;
    if (rate <= 0.05) return CancellationLevel.rarely;
    if (rate <= 0.12) return CancellationLevel.sometimes;
    return CancellationLevel.often;
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _profileProvider = FreelancerPublicProfileProvider();
    _profileProvider.addListener(() {
      if (mounted) setState(() {});
    });
    _profileProvider.load(widget.freelancerId);
  }

  @override
  void dispose() {
    _profileProvider.dispose();
    super.dispose();
  }

  // ── BaseProfileState overrides ──────────────────────────────────────────────

  // Le tarif vit dans les stats ; la ligne grade reste sans trailing.
  @override
  String? get profileMetaTrailing => null;

  @override
  List<ProfileStatData> buildProfileStats() => [
    ProfileStatData(
      icon: Icons.workspace_premium_rounded,
      value: _experienceStat,
      label: 'Expérience',
    ),
    ProfileStatData(
      icon: Icons.task_alt_rounded,
      value: '$_missionsCount',
      label: 'Missions',
    ),
    ProfileStatData(
      icon: Icons.sell_outlined,
      value: '${_rate.toInt()}€/h',
      label: 'Tarif',
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
    VerifiedItemData(
      label: _cancellationLevel.label,
      verified:
          _cancellationLevel == CancellationLevel.never ||
          _cancellationLevel == CancellationLevel.rarely,
      warning: _cancellationLevel == CancellationLevel.sometimes,
      icon: Icons.event_busy_rounded,
    ),
  ];

  @override
  Widget? buildProposalSection(BuildContext context) {
    if (widget.proposedPrice == null) return null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.proposedPrice!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.successDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildExtraSection(BuildContext context) {
    final center = _latitude != null && _longitude != null
        ? LatLng(_latitude!, _longitude!)
        : const LatLng(48.8566, 2.3522);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: 'Présentation'),
          AppGap.h8,
          _bio.isNotEmpty
              ? Text(
                  _bio,
                  style: context.text.bodyMedium?.copyWith(
                    height: 1.65,
                    color: context.colors.textSecondary,
                  ),
                )
              : Text(
                  "Ce prestataire n'a pas encore rédigé sa présentation.",
                  style: context.text.bodyMedium?.copyWith(
                    height: 1.6,
                    color: context.colors.textHint,
                  ),
                ),
          AppGap.h28,
          const ProfileSectionTitle(title: 'Localisation'),
          AppGap.h10,
          Container(
            height: 182,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
              border: Border.all(color: AppColors.gray50),
            ),
            clipBehavior: Clip.hardEdge,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 12,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.fourhorses.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 40,
                      height: 40,
                      child: const _MapMarker(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_address.isNotEmpty) ...[
            AppGap.h12,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: context.colors.textHint,
                  ),
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    _address,
                    style: context.text.titleSmall?.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          AppGap.h8,
          Text(
            "Zone d'intervention : ${_zoneRadius.toInt()} km autour de "
            "${_address.isNotEmpty ? _address : 'sa position'}",
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  String get contactButtonLabel {
    if (isOpeningChat) return 'Connexion...';
    return widget.contactMode == FreelancerContactMode.pendingCandidate
        ? 'Contacter & Accepter'
        : 'Contacter';
  }

  @override
  VoidCallback? buildReserveAction(BuildContext context) {
    // Réservation directe uniquement en démarchage spontané —
    // dans les autres modes, le contexte mission existe déjà.
    if (widget.contactMode != FreelancerContactMode.spontaneous) return null;
    final freelancerId = widget.freelancerId;
    if (freelancerId == null) return null;
    return () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostMissionFlow(
          preAssignedFreelancerId: freelancerId,
          preAssignedFreelancerName: profileName,
          preAssignedFreelancerAvatar: profileAvatar,
        ),
      ),
    );
  }

  @override
  Future<String?> resolveConversationId(BuildContext context) async {
    if (widget.freelancerId == null) return null;
    return context.read<MessagingProvider>().getOrCreateConversation(
      otherUserId: widget.freelancerId!,
      iAmClient: true,
    );
  }

  @override
  Widget buildChatPage(String? conversationId) {
    final isPending =
        widget.contactMode == FreelancerContactMode.pendingCandidate;
    final isSpontaneous =
        widget.contactMode == FreelancerContactMode.spontaneous;
    final isConfirmed =
        widget.contactMode == FreelancerContactMode.confirmedPresta;
    return ChatPage(
      conversationId: conversationId,
      contactUserId: widget.freelancerId,
      contactName: profileName,
      contactAvatar: profileAvatar,
      isVerified: true,
      candidateMode: isPending,
      candidatePrice: isPending ? widget.candidatePrice : null,
      onAcceptCandidate: isPending ? widget.onCandidateAccepted : null,
      showReserveButton: isSpontaneous,
      freelancerId: isSpontaneous ? widget.freelancerId : null,
      confirmedMissionTitle: isConfirmed ? widget.confirmedMissionTitle : null,
      isMissionConfirmed: isConfirmed,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
}

// ── Widgets spécifiques freelancer ────────────────────────────────────────────

class _MapMarker extends StatelessWidget {
  const _MapMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.inkDark,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(16, 20, 24, 0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.place_outlined,
            color: Colors.white,
            size: 16,
          ),
        ),
        CustomPaint(size: const Size(10, 6), painter: _PinTailPainter()),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.inkDark;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Stories bar (info tab) ────────────────────────────────────────────────────

class _FreelancerPublicationsContent extends StatefulWidget {
  final String freelancerId;
  const _FreelancerPublicationsContent({required this.freelancerId});

  @override
  State<_FreelancerPublicationsContent> createState() =>
      _FreelancerPublicationsContentState();
}

class _FreelancerPublicationsContentState
    extends State<_FreelancerPublicationsContent> {
  void _openPost(BuildContext context, Story story) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            PostPhotosViewer(images: story.images, caption: story.caption),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final groups = provider.storyGroupsForFreelancer(widget.freelancerId);
    final stories = groups.expand((g) => g.stories).toList();

    if (provider.isLoading && stories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (stories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 26,
                  color: context.colors.textSecondary,
                ),
              ),
              AppGap.h16,
              Text(
                'Aucune publication',
                style: context.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppGap.h6,
              Text(
                "Ce prestataire n'a pas encore publié de contenu.",
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      // Rendu dans la Column scrollable du profil : hauteur intrinsèque
      // obligatoire, le scroll est géré par le SingleChildScrollView parent.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: stories.length,
      itemBuilder: (context, i) {
        final story = stories[i];
        return GestureDetector(
          onTap: () => _openPost(context, story),
          child: Stack(
            fit: StackFit.expand,
            children: [
              story.imageUrl.isNotEmpty
                  ? Image.network(
                      story.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.secondary,
                        child: const Icon(
                          Icons.image_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.secondary,
                      child: const Icon(
                        Icons.image_rounded,
                        color: AppColors.primary,
                      ),
                    ),
              // Badge multi-photos (coin haut droit)
              if (story.images.length > 1)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Icon(
                    Icons.collections_rounded,
                    size: 14,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              // Compteur ♥ (coin bas gauche) — identité « post »
              if (story.likesCount > 0)
                Positioned(
                  left: 5,
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 12,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      AppGap.w3,
                      Text(
                        '${story.likesCount}',
                        style: context.text.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
