import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../messaging/messaging_provider.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
import '../../../profile/presentation/pages/shared/base_profile_view.dart';
import '../../../story/story.dart';
import '../providers/freelancer_public_profile_provider.dart';

export '../../../profile/presentation/pages/shared/base_profile_view.dart'
    show ProfileStatData, VerifiedItemData, CancellationLevel, CancellationLevelExtension;

// ─── Enums ────────────────────────────────────────────────────────────────────

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
  double get profileRating =>
      _profileProvider.profile?.rating ?? widget.rating;

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

  @override
  Widget? buildStoriesBar(BuildContext context) {
    if (widget.freelancerId == null) return null;
    return _FreelancerStoriesBar(
      freelancerId: widget.freelancerId!,
      selectedCategories: _profileProvider.profile?.serviceCategories ?? const [],
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

  String get _responseStat {
    final dbRaw = _profileProvider.profile?.responseTime?.trim();
    if (dbRaw != null && dbRaw.isNotEmpty) return dbRaw;
    final raw = widget.responseTime?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return '15 min';
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

  @override
  Widget buildHeroBadge(BuildContext context) =>
      _HeroRateBadge(rate: _rate, context: context);

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
          icon: Icons.schedule_outlined,
          value: _responseStat,
          label: 'Réponse',
        ),
      ];

  @override
  List<VerifiedItemData> get verifiedItems => [
        const VerifiedItemData(label: "Pièce d'identité vérifiée", verified: true),
        const VerifiedItemData(label: 'Adresse e-mail vérifiée', verified: true),
        const VerifiedItemData(label: 'Numéro de téléphone vérifié', verified: true),
        VerifiedItemData(
          label: _cancellationLevel.label,
          verified: _cancellationLevel == CancellationLevel.never ||
              _cancellationLevel == CancellationLevel.rarely,
          warning: _cancellationLevel == CancellationLevel.sometimes,
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
          AppGap.h12,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: const [
                BoxShadow(color: AppColors.blackAlpha03, blurRadius: 24, offset: Offset(0, 10)),
              ],
            ),
            child: _bio.isNotEmpty
                ? Text(
                    _bio,
                    style: context.text.bodyMedium
                        ?.copyWith(height: 1.65, color: context.colors.textSecondary),
                  )
                : Text(
                    "Ce prestataire n'a pas encore rédigé sa présentation.",
                    style: context.text.bodyMedium
                        ?.copyWith(height: 1.6, color: context.colors.textHint),
                  ),
          ),
          AppGap.h24,
          const ProfileSectionTitle(title: 'Localisation'),
          AppGap.h12,
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: const [
                BoxShadow(color: AppColors.blackAlpha03, blurRadius: 24, offset: Offset(0, 10)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          userAgentPackageName: 'com.example.homservice',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: center,
                              width: 40,
                              height: 40,
                              child: const AppMapPin(color: AppColors.inkDark, size: 28),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_address.isNotEmpty) ...[
                    AppGap.h14,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(Icons.location_on_outlined,
                              size: 16, color: context.colors.textHint),
                        ),
                        AppGap.w8,
                        Expanded(
                          child: Text(
                            _address,
                            style: context.text.titleSmall
                                ?.copyWith(height: 1.35, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppGap.h10,
          Text(
            "Zone d'intervention : ${_zoneRadius.toInt()} km autour de "
            "${_address.isNotEmpty ? _address : 'sa position'}",
            style: context.text.labelSmall
                ?.copyWith(color: context.colors.textSecondary),
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
    final isConfirmed = widget.contactMode == FreelancerContactMode.confirmedPresta;
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


}

// ── Widgets spécifiques freelancer ────────────────────────────────────────────

class _HeroRateBadge extends StatelessWidget {
  final double rate;
  final BuildContext context;
  const _HeroRateBadge({required this.rate, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 0.9),
        boxShadow: const [
          BoxShadow(color: AppColors.blackAlpha15, blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '${rate.toInt()}€/h',
            style: ctx.text.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stories bar (info tab) ────────────────────────────────────────────────────

class _FreelancerStoriesBar extends StatefulWidget {
  final String freelancerId;
  final List<String> selectedCategories;

  const _FreelancerStoriesBar({
    required this.freelancerId,
    required this.selectedCategories,
  });

  @override
  State<_FreelancerStoriesBar> createState() => _FreelancerStoriesBarState();
}

class _FreelancerStoriesBarState extends State<_FreelancerStoriesBar> {
  final Set<String> _viewed = {};

  void _openViewer(BuildContext context, List<StoryGroup> groups, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: index,
          onViewed: (groupId) => setState(() => _viewed.add(groupId)),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = context
        .watch<StoryProvider>()
        .storyGroupsForFreelancer(widget.freelancerId);
    final entries = CategoryStoryEntries.build(
      selectedCategories: widget.selectedCategories,
      groups: groups,
    );
    if (entries.isEmpty) return const SizedBox.shrink();

    final items = entries
        .map((entry) {
          final viewed = entry.hasStories ? _viewed.contains(entry.categoryId) : true;
          return CategoryStoryStripItem(
            categoryId: entry.categoryId,
            label: entry.label,
            count: entry.count,
            viewed: viewed,
            onTap: entry.hasStories
                ? () {
                    final index =
                        groups.indexWhere((g) => g.groupId == entry.categoryId);
                    if (index >= 0) _openViewer(context, groups, index);
                  }
                : null,
          );
        })
        .toList(growable: false);

    return CategoryStoryStrip(items: items);
  }
}

// ── Publications tab ──────────────────────────────────────────────────────────

class _FreelancerPublicationsContent extends StatefulWidget {
  final String freelancerId;
  const _FreelancerPublicationsContent({required this.freelancerId});

  @override
  State<_FreelancerPublicationsContent> createState() =>
      _FreelancerPublicationsContentState();
}

class _FreelancerPublicationsContentState
    extends State<_FreelancerPublicationsContent> {
  void _openViewer(
      BuildContext context, List<StoryGroup> groups, Story story) {
    final groupIdx = groups.indexWhere((g) => g.stories.contains(story));
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewerPage(
          groups: groups,
          initialIndex: groupIdx >= 0 ? groupIdx : 0,
          onViewed: (_) {},
        ),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (stories.isEmpty) {
      return Center(
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
              child: Icon(Icons.auto_stories_rounded,
                  size: 26, color: context.colors.textSecondary),
            ),
            AppGap.h16,
            Text(
              'Aucune publication',
              style: context.text.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppGap.h6,
            Text(
              "Ce prestataire n'a pas encore publié de contenu.",
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary, height: 1.4),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
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
          onTap: () => _openViewer(context, groups, story),
          child: Stack(
            fit: StackFit.expand,
            children: [
              story.imageUrl.isNotEmpty
                  ? Image.network(
                      story.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.secondary,
                        child: const Icon(Icons.image_rounded,
                            color: AppColors.primary),
                      ),
                    )
                  : Container(
                      color: AppColors.secondary,
                      child: const Icon(Icons.image_rounded,
                          color: AppColors.primary),
                    ),
              if (story.caption.isNotEmpty)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0, 0.7],
                        colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                      ),
                    ),
                    child: Text(
                      story.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: AppFontSize.tiny),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
