import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/auth_provider.dart';
import '../../../../../app/enum/user_role.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../reviews/data/repositories/supabase_review_repository.dart';
import '../../../../reviews/domain/entities/review.dart';
import '../../../../reviews/presentation/widgets/review_card.dart';
import '../../../../reviews/presentation/widgets/reviews_summary.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Data classes
/// ═══════════════════════════════════════════════════════════════════════════

class ProfileStatData {
  final IconData icon;
  final String value;
  final String label;
  const ProfileStatData({
    required this.icon,
    required this.value,
    required this.label,
  });
}

class VerifiedItemData {
  final String label;
  final bool verified;
  final bool warning;

  /// Icône thématique de la ligne (pièce d'identité, e-mail, téléphone…)
  final IconData icon;

  const VerifiedItemData({
    required this.label,
    this.verified = false,
    this.warning = false,
    this.icon = Icons.verified_user_outlined,
  });
}

enum _ProfileContentTab { publications, information, reviews }

/// ═══════════════════════════════════════════════════════════════════════════
/// BaseProfileState — Template Method
///
/// Sous-classes :
///   _FreelancerProfilePageState  →  tarif €/h, bio DB, carte map
///   _ClientProfileViewState      →  rating étoiles, bio auto, pas de map
/// ═══════════════════════════════════════════════════════════════════════════

abstract class BaseProfileState<T extends StatefulWidget> extends State<T> {
  bool isOpeningChat = false;
  final SupabaseReviewRepository _reviewsRepository =
      SupabaseReviewRepository();
  _ProfileContentTab? _selectedTab;

  _ProfileContentTab get _activeTab =>
      _selectedTab ??
      (showPublicationsTab
          ? _ProfileContentTab.publications
          : _ProfileContentTab.information);
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

  /// Ligne sous le nom (métier, ancienneté…) — style @handle TikTok
  String get profileSubtitle => '';

  /// Bio courte affichée dans la pilule pleine largeur du header
  String get profileBio => '';

  /// Badge posé sur l'avatar (vérifié, dispo…) — coin bas-droit
  Widget? buildAvatarBadge(BuildContext context) => null;

  /// Texte affiché après le grade, séparé par « | » (ex. tarif « 45€/h »)
  String? get profileMetaTrailing => null;

  /// 3 cellules de stats
  List<ProfileStatData> buildProfileStats();

  /// Section optionnelle sous les stats (bio + map pour freelancer)
  Widget? buildExtraSection(BuildContext context) => null;

  /// Card offre de prix (candidature) — uniquement freelancer
  Widget? buildProposalSection(BuildContext context) => null;

  /// Éléments de la section "Informations vérifiées"
  List<VerifiedItemData> get verifiedItems;

  /// Contenu de l'onglet grille (publications)
  Widget buildPublicationsContent(BuildContext context) =>
      const SizedBox.shrink();

  /// Construit le ChatPage à ouvrir (params différents selon le rôle)
  Widget buildChatPage(String? conversationId);

  /// Résout (ou crée) la conversation — retourne l'ID ou null
  Future<String?> resolveConversationId(BuildContext context);

  /// Label du bouton bas (peut être surchargé)
  String get contactButtonLabel => 'Contacter';

  /// Action « Réserver » optionnelle — si non-null, le bas de page devient
  /// double CTA : Contacter (secondaire) + Réserver (principal noir).
  VoidCallback? buildReserveAction(BuildContext context) => null;

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
    final canContact =
        auth.currentRole != UserRole.provider &&
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
                  border: Border(
                    top: BorderSide(color: context.colors.divider),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    final reserve = buildReserveAction(context);
                    final contactBtn = AppButton(
                      label: isOpeningChat ? 'Connexion...' : contactButtonLabel,
                      variant: reserve == null
                          ? ButtonVariant.black
                          : ButtonVariant.outline,
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: isOpeningChat ? null : () => openChat(context),
                    );
                    if (reserve == null) return contactBtn;
                    return Row(
                      children: [
                        Expanded(child: contactBtn),
                        AppGap.w10,
                        Expanded(
                          child: AppButton(
                            label: 'Réserver',
                            variant: ButtonVariant.black,
                            icon: Icons.event_available_rounded,
                            onPressed: reserve,
                          ),
                        ),
                      ],
                    );
                  },
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

  // ── Header façon TikTok : nom à gauche, avatar à droite ──────────────────

  Widget _buildProfileHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final stats = buildProfileStats();

    return Container(
      color: context.colors.background,
      padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoadingProfile)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          // Flèche de retour complète façon TikTok : icône noire nue,
          // sans cercle — zone de tap 44px conservée.
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 26,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),
          AppGap.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.displaySmall,
                    ),
                    if (profileSubtitle.isNotEmpty) ...[
                      AppGap.h4,
                      Text(
                        profileSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                    AppGap.h8,
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profileLevel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (profileMetaTrailing != null) ...[
                          Text(
                            '  |  ',
                            style: context.text.labelLarge?.copyWith(
                              color: context.colors.textHint,
                            ),
                          ),
                          Text(
                            profileMetaTrailing!,
                            style: context.text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppGap.h14,
                    Row(
                      children: [
                        for (int i = 0; i < stats.length; i++) ...[
                          if (i > 0) AppGap.w20,
                          _ProfileHeaderStat(
                            value: stats[i].value,
                            label: stats[i].label,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              AppGap.w16,
              _buildHeaderAvatar(context),
            ],
          ),
          if (profileBio.isNotEmpty) ...[
            AppGap.h16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                profileBio,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderAvatar(BuildContext context) {
    final badge = buildAvatarBadge(context);
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: SizedBox(
              width: 96,
              height: 96,
              child: profileAvatar.isNotEmpty
                  ? Image.network(
                      profileAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => _buildAvatarFallback(ctx),
                    )
                  : _buildAvatarFallback(context),
            ),
          ),
          if (badge != null) Positioned(right: -2, bottom: 0, child: badge),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(BuildContext context) => Container(
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.surface, AppColors.surfaceAlt],
      ),
    ),
    child: Text(
      profileName.isNotEmpty ? profileName[0].toUpperCase() : '?',
      style: context.text.displaySmall?.copyWith(
        color: context.colors.textTertiary,
      ),
    ),
  );

  // ── Tabs icônes façon TikTok (underline) ──────────────────────────────────

  Widget _buildTabPills(BuildContext context) {
    final tabs = <_ProfileContentTab>[
      if (showPublicationsTab) _ProfileContentTab.publications,
      _ProfileContentTab.information,
      _ProfileContentTab.reviews,
    ];

    IconData iconFor(_ProfileContentTab tab, bool active) {
      switch (tab) {
        case _ProfileContentTab.publications:
          return Icons.grid_on_rounded;
        case _ProfileContentTab.information:
          return active ? Icons.info_rounded : Icons.info_outline_rounded;
        case _ProfileContentTab.reviews:
          return active ? Icons.star_rounded : Icons.star_border_rounded;
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.divider)),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: _ProfileIconTab(
                icon: iconFor(tab, _activeTab == tab),
                active: _activeTab == tab,
                onTap: () => _selectTab(tab),
              ),
            ),
        ],
      ),
    );
  }

  void _selectTab(_ProfileContentTab tab) {
    if (_activeTab == tab) return;

    setState(() => _selectedTab = tab);
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
    switch (_activeTab) {
      case _ProfileContentTab.reviews:
        return _buildReviewsSection(context);

      case _ProfileContentTab.publications:
        return buildPublicationsContent(context);

      case _ProfileContentTab.information:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Respiration sous la barre d'onglets
            AppGap.h16,
            if (proposal != null) proposal,
            _buildVerifiedSection(context),
            if (extra != null) extra,
          ],
        );
    }
  }

  Widget _buildReviewsSection(BuildContext context) {
    if (_isLoadingReviews && !_hasLoadedReviews) {
      return Padding(
        padding: const EdgeInsets.only(top: 36),
        child: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
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

  // ── Informations vérifiées ────────────────────────────────────────────────

  Widget _buildVerifiedSection(BuildContext context) {
    final items = verifiedItems;
    final verifiedCount = items.where((i) => i.verified).length;
    final allVerified = verifiedCount == items.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ProfileSectionTitle(title: 'Profil vérifié'),
              AppGap.w8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: allVerified
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$verifiedCount/${items.length}',
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: allVerified
                        ? AppColors.successDark
                        : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h4,
          Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: context.colors.divider, indent: 30),
                ProfileVerificationItem(
                  label: items[i].label,
                  verified: items[i].verified,
                  warning: items[i].warning,
                  icon: items[i].icon,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// Widgets partagés (public pour être utilisés dans les sous-classes)
/// ═══════════════════════════════════════════════════════════════════════════

class ProfileTabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const ProfileTabPill({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.inkDark : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.inkDark : AppColors.gray50,
          ),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: AppColors.blackAlpha09,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: active ? Colors.white : AppColors.gray600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.inkDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat du header façon TikTok : valeur en gras au-dessus, label dessous.
class _ProfileHeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileHeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
            height: 1.1,
          ),
        ),
        AppGap.h2,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.labelMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Onglet icône avec soulignement façon TikTok.
class _ProfileIconTab extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ProfileIconTab({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Icon(
              icon,
              size: 22,
              color: active
                  ? context.colors.textPrimary
                  : context.colors.textHint,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2,
            width: 28,
            color: active ? context.colors.textPrimary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

/// Titre de section : texte noir sur fond blanc, sobre et net —
/// même langage que le header (pas de carte, pas de couleur).
class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.text.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
    );
  }
}

class ProfileVerificationItem extends StatelessWidget {
  final String label;
  final bool verified;
  final bool warning;
  final IconData icon;

  const ProfileVerificationItem({
    super.key,
    required this.label,
    this.verified = false,
    this.warning = false,
    this.icon = Icons.verified_user_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final Color tint;
    final IconData statusIcon;

    if (warning) {
      tint = AppColors.warning;
      statusIcon = Icons.warning_amber_rounded;
    } else if (verified) {
      // Vérifié = état normal : coche neutre et discrète, la couleur est
      // réservée aux états qui demandent l'attention (warning / erreur).
      tint = context.colors.textSecondary;
      statusIcon = Icons.check_rounded;
    } else {
      tint = AppColors.error;
      statusIcon = Icons.cancel_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.colors.textSecondary),
          AppGap.w12,
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(statusIcon, size: 18, color: tint),
        ],
      ),
    );
  }
}
