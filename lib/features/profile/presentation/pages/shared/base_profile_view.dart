import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/enum/user_role.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../mission/presentation/widgets/detail/mission_detail_primitives.dart';
import '../../../../reviews/data/repositories/supabase_review_repository.dart';
import '../../../../reviews/domain/entities/review.dart';
import '../../../../reviews/presentation/widgets/review_card.dart';
import '../../../../reviews/presentation/widgets/reviews_summary.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Shared enums
/// ═══════════════════════════════════════════════════════════════════════════

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

/// ═══════════════════════════════════════════════════════════════════════════
/// Data classes
/// ═══════════════════════════════════════════════════════════════════════════

class ProfileStatData {
  final IconData icon;
  final String value;
  final String label;
  const ProfileStatData({required this.icon, required this.value, required this.label});
}

class VerifiedItemData {
  final String label;
  final bool verified;
  final bool warning;
  const VerifiedItemData({required this.label, this.verified = false, this.warning = false});
}

enum _ProfileContentTab { information, reviews }

/// ═══════════════════════════════════════════════════════════════════════════
/// BaseProfileState — Template Method
///
/// Sous-classes :
///   _FreelancerProfilePageState  →  tarif €/h, bio DB, carte map
///   _ClientProfileViewState      →  rating étoiles, bio auto, pas de map
/// ═══════════════════════════════════════════════════════════════════════════

abstract class BaseProfileState<T extends StatefulWidget> extends State<T> {
  bool isOpeningChat = false;
  final SupabaseReviewRepository _reviewsRepository = SupabaseReviewRepository();
  _ProfileContentTab _activeTab = _ProfileContentTab.information;
  List<Review> _profileReviews = const [];
  bool _isLoadingReviews = false;
  bool _hasLoadedReviews = false;
  String? _reviewsError;

  // ── À fournir par la sous-classe ─────────────────────────────────────────

  String get profileName;
  String get profileAvatar;
  double get profileRating;
  int get profileReviewsCount;
  String get profileLevel;
  bool get isLoadingProfile;
  String? get profileUserId => null;
  String get expectedReviewerUserType;
  bool get showPublicationsTab => false;

  /// Badge hero haut-droite (tarif chez freelancer, rating chez client)
  Widget buildHeroBadge(BuildContext context);

  /// 3 cellules de stats
  List<ProfileStatData> buildProfileStats();

  /// Section optionnelle sous les stats (bio + map pour freelancer)
  Widget? buildExtraSection(BuildContext context) => null;

  /// Card offre de prix (candidature) — uniquement freelancer
  Widget? buildProposalSection(BuildContext context) => null;

  /// Éléments de la section "Informations vérifiées"
  List<VerifiedItemData> get verifiedItems;

  /// Ouvre la page avis
  Widget? buildStoriesBar(BuildContext context) => null;
  Widget buildPublicationsContent(BuildContext context) => const SizedBox.shrink();

  /// Construit le ChatPage à ouvrir (params différents selon le rôle)
  Widget buildChatPage(String? conversationId);

  /// Résout (ou crée) la conversation — retourne l'ID ou null
  Future<String?> resolveConversationId(BuildContext context);

  /// Label du bouton bas (peut être surchargé)
  String get contactButtonLabel => 'Contacter';

  // ── Chat — implémentation commune ────────────────────────────────────────

  Future<void> openChat(BuildContext context) async {
    if (isOpeningChat) return;
    setState(() => isOpeningChat = true);

    String? conversationId;
    try {
      conversationId = await resolveConversationId(context);
    } catch (_) {}

    if (!mounted) return;
    setState(() => isOpeningChat = false);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => buildChatPage(conversationId)),
    );
  }

  // ── Template build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canContact = auth.currentRole != UserRole.provider &&
        (profileUserId == null || profileUserId != auth.userId);
    final proposal = buildProposalSection(context);
    final extra = buildExtraSection(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      bottomNavigationBar: canContact
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  border: Border(top: BorderSide(color: context.colors.divider)),
                ),
                child: AppButton(
                  label: isOpeningChat ? 'Connexion...' : contactButtonLabel,
                  variant: ButtonVariant.black,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: isOpeningChat ? null : () => openChat(context),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          _buildProfileHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabPills(context),
                  _buildTabContent(context, proposal: proposal, extra: extra),
                  AppGap.h32,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header photo plein écran ──────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        if (isLoadingProfile) const LinearProgressIndicator(minHeight: 2),
        SizedBox(
          height: 290,
          child: Stack(
            children: [
              Positioned.fill(
                child: profileAvatar.isNotEmpty
                    ? Image.network(
                        profileAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                      )
                    : _buildAvatarFallback(),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.78),
                          Colors.black.withValues(alpha: 0.32),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.28, 0.62],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topPad + 4,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    DetailCircleBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    buildHeroBadge(context),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 34,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.08,
                        color: Colors.white,
                        letterSpacing: -0.9,
                      ),
                    ),
                    AppGap.h10,
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: ProfileLevelPill(level: profileLevel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.surfaceAlt],
          ),
        ),
      );

  // ── Tab pills ─────────────────────────────────────────────────────────────

  Widget _buildTabPills(BuildContext context) {
    return AppSegmentedTabBar(
      tabs: [
        const AppSegmentedTab(
          icon: Icons.info_outline_rounded,
          label: 'Information',
        ),
        AppSegmentedTab(
          icon: Icons.star_rounded,
          label: '${profileRating.toStringAsFixed(1)} · $profileReviewsCount avis',
        ),
      ],
      selectedIndex: _activeTab.index,
      onChanged: (i) => _selectTab(_ProfileContentTab.values[i]),
    );
  }

  void _selectTab(_ProfileContentTab tab) {
    if (_activeTab == tab) return;

    setState(() => _activeTab = tab);
    if (tab == _ProfileContentTab.reviews && !_hasLoadedReviews) {
      _loadProfileReviews();
    }
  }

  Future<void> _loadProfileReviews() async {
    final userId = profileUserId;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _hasLoadedReviews = true;
        _isLoadingReviews = false;
        _profileReviews = const [];
        _reviewsError = 'Impossible de charger les avis (profil introuvable)';
      });
      return;
    }

    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final reviews = await _reviewsRepository.getReceivedReviewsByReviewerType(
        revieweeId: userId,
        reviewerUserType: expectedReviewerUserType,
      );
      if (!mounted) return;
      setState(() {
        _profileReviews = reviews;
        _hasLoadedReviews = true;
        _reviewsError = null;
        _isLoadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profileReviews = const [];
        _hasLoadedReviews = true;
        _reviewsError = 'Impossible de charger les avis';
        _isLoadingReviews = false;
      });
    }
  }

  Widget _buildTabContent(
    BuildContext context, {
    required Widget? proposal,
    required Widget? extra,
  }) {
    if (_activeTab == _ProfileContentTab.reviews) {
      return _buildReviewsSection(context);
    }

    final stories = buildStoriesBar(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (proposal != null) proposal,
        _buildProfileMetaSection(context),
        if (stories != null) stories,
        _buildVerifiedSection(context),
        if (extra != null) extra,
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    if (_isLoadingReviews && !_hasLoadedReviews) {
      return Padding(
        padding: const EdgeInsets.only(top: 36),
        child: Center(child: CircularProgressIndicator(color: context.colors.primary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewsSummary(reviews: _profileReviews),
        if (_reviewsError != null && _profileReviews.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: AppSurfaceCard(
              padding: const EdgeInsets.all(16),
              border: Border.all(color: context.colors.border),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: context.colors.textSecondary,
                    size: 18,
                  ),
                  AppGap.w10,
                  Expanded(
                    child: Text(
                      _reviewsError!,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                  AppGap.w10,
                  TextButton(
                    onPressed: _loadProfileReviews,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        if (_profileReviews.isEmpty && _reviewsError == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              border: Border.all(color: context.colors.border),
              child: Row(
                children: [
                  Icon(
                    Icons.sentiment_neutral_rounded,
                    size: 22,
                    color: context.colors.textHint,
                  ),
                  AppGap.w10,
                  Expanded(
                    child: Text(
                      'Aucun avis pour le moment',
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_profileReviews.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                for (final review in _profileReviews) ...[
                  ReviewCard(review: review, isReceived: true),
                  AppGap.h12,
                ],
              ],
            ),
          ),
      ],
    );
  }

  // ── Stats card ────────────────────────────────────────────────────────────

  Widget _buildProfileMetaSection(BuildContext context) {
    final stats = buildProfileStats();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: context.colors.border),
          boxShadow: const [
            BoxShadow(color: AppColors.blackAlpha03, blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              if (i > 0) const ProfileStatDivider(),
              Expanded(
                child: ProfileStatCell(
                  icon: stats[i].icon,
                  value: stats[i].value,
                  label: stats[i].label,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Informations vérifiées ────────────────────────────────────────────────

  Widget _buildVerifiedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: 'Informations vérifiées'),
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
            child: Column(
              children: [
                for (int i = 0; i < verifiedItems.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: context.colors.divider, indent: 31),
                  ProfileVerificationItem(
                    label: verifiedItems[i].label,
                    verified: verifiedItems[i].verified,
                    warning: verifiedItems[i].warning,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Widgets partagés (public pour être utilisés dans les sous-classes)
/// ═══════════════════════════════════════════════════════════════════════════

class ProfileLevelPill extends StatelessWidget {
  final String level;
  const ProfileLevelPill({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final lower = level.toLowerCase();
    final IconData icon;
    if (lower == 'ambassadeur') {
      icon = Icons.workspace_premium_rounded;
    } else if (lower == 'expert') {
      icon = Icons.military_tech_rounded;
    } else if (lower == 'pro') {
      icon = Icons.verified_rounded;
    } else {
      icon = Icons.person_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gray50, width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gray600),
          const SizedBox(width: 5),
          Text(level, style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ProfileStatDivider extends StatelessWidget {
  const ProfileStatDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 42, color: AppColors.gray50);
}

class ProfileStatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const ProfileStatCell({super.key, required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.gray600),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class ProfileVerificationItem extends StatelessWidget {
  final String label;
  final bool verified;
  final bool warning;

  const ProfileVerificationItem({
    super.key,
    required this.label,
    this.verified = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData iconData;

    if (warning) {
      iconColor = AppColors.warning;
      iconData = Icons.warning_amber_rounded;
    } else if (verified) {
      iconColor = AppColors.successDark;
      iconData = Icons.check_circle_rounded;
    } else {
      iconColor = AppColors.error;
      iconData = Icons.cancel_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(iconData, size: 17, color: iconColor),
          AppGap.w14,
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
