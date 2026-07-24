import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../../pages/shared/mission_map_page.dart';
import '../shared/status_timeline.dart';
import 'mission_detail_hero.dart';
import 'mission_detail_primitives.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MissionDetailBase — Template Method Pattern
///
/// Squelette de page mission (layout fixe) avec slots abstraits par rôle.
/// Ne contient aucun `if (isClient)` ni `if (isFreelancer)`.
/// ═══════════════════════════════════════════════════════════════════════════

abstract class MissionDetailBase<T extends StatefulWidget> extends State<T> {
  late Mission mission;

  // ─── Abstract — fournis par chaque rôle ────────────────────────────────────

  /// Mission initiale depuis le widget
  Mission get widgetMission;

  /// Synchronisation live depuis le Provider (appelé à chaque build)
  Mission syncMission(BuildContext ctx);

  /// Config data de la bannière status → null = pas de bannière
  StatusBannerConfig? resolveBanner();

  /// Pills + budget (différent client / freelancer)
  Widget buildTagsPrice(BuildContext ctx);

  /// Section rôle-spécifique (presta card ou client card)
  Widget buildRoleSection(BuildContext ctx);

  /// Carte finance exposée (retourne null si non pertinente)
  Widget? buildFinanceExposureCard(BuildContext ctx);

  /// CTA bas de page
  Widget buildBottom(BuildContext ctx);

  /// Bouton menu dans le hero (⋯) — null = pas de bouton
  Widget? buildHeroMenu(BuildContext ctx);

  /// Afficher la StatusTimeline ?
  bool get showTimeline;

  /// Cacher le bottom (ex: isReadOnly côté client)
  bool get isBottomHidden;

  /// Révéler l'adresse complète et la carte interactive.
  /// false = mission publique non encore attribuée au viewer.
  bool get canSeeFullAddress;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    mission = widgetMission;
  }

  // ─── Template Method — build squelette fixe ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    mission = syncMission(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final financeExposureCard = buildFinanceExposureCard(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero (fixe, non scrollable) ──────────────────────────────────
          MissionDetailHero(
            mission: mission,
            onBack: () => Navigator.pop(context),
            menuButton: buildHeroMenu(context),
          ),

          // ── Header (fixe, non scrollable) ────────────────────────────────
          AppGap.h20,
          Padding(
            padding: AppInsets.h16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                AppGap.h16,
                buildTagsPrice(context),
              ],
            ),
          ),
          AppGap.h20,

          // ── Corps scrollable ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTimeline)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: StatusTimeline(status: mission.status),
                    ),
                  if (financeExposureCard != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: financeExposureCard,
                    ),
                  _buildMap(context),
                  AppGap.h20,
                  _buildDescription(context),
                  AppGap.h20,
                  _buildStatusBanner(context),
                  buildRoleSection(context),
                  AppGap.h32,
                ],
              ),
            ),
          ),

          // ── Bottom fixe ──────────────────────────────────────────────────
          if (!isBottomHidden) buildBottom(context),
        ],
      ),
    );
  }

  // ─── Sections concrètes partagées ──────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Catégorie + sous-catégorie directement sous l'image du hero
        Text(
          mission.categoryName.toUpperCase(),
          style: context.missionCategoryStyle,
        ),
        AppGap.h6,
        Text(
          mission.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        AppGap.h12,
        Row(
          children: [
            Expanded(
              child: DetailMetaChip(
                icon: Icons.calendar_today_outlined,
                label: mission.formattedDate,
              ),
            ),
            const DetailInlineDivider(),
            Expanded(
              child: DetailMetaChip(
                icon: Icons.schedule_outlined,
                label: mission.timeSlot,
              ),
            ),
            const DetailInlineDivider(),
            Expanded(
              child: DetailMetaChip(
                icon: Icons.location_on_outlined,
                label: mission.address.shortAddress,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Sections à plat sur fond blanc — même langage que les profils :
  // pas de carte-boîte, la map garde seulement son cadre arrondi.
  Widget _buildMap(BuildContext context) {
    return Padding(
      padding: AppInsets.h16,
      child: canSeeFullAddress
          ? _buildFullMap(context)
          : _buildLockedAddress(context),
    );
  }

  /// Adresse en texte direct, carte plein écran à un tap — plus de
  /// preview de map incrustée (économie d'écran et de tuiles réseau).
  Widget _buildFullMap(BuildContext context) {
    final address = mission.address.fullAddress.isNotEmpty
        ? mission.address.fullAddress
        : mission.address.shortAddress;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MissionMapPage(address: mission.address),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_on_outlined,
                size: 18,
                color: context.colors.textTertiary,
              ),
            ),
            AppGap.w10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address,
                    style: context.missionBodyStyle.copyWith(
                      height: 1.35,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  AppGap.h2,
                  Text(
                    'Voir sur la carte',
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedAddress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: context.colors.textSecondary,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.address.shortAddress.isNotEmpty
                      ? mission.address.shortAddress
                      : 'Adresse non disponible',
                  style: context.missionBodyStyle.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                AppGap.h4,
                Text(
                  'Adresse complète disponible après confirmation',
                  style: context.missionBodyStyle.copyWith(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: AppInsets.h16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: context.missionSectionTitleStyle),
          AppGap.h8,
          Text(mission.description, style: context.missionBodyStyle),
        ],
      ),
    );
  }

  /// Rendu centralisé — la base rend, les rôles fournissent les données
  Widget _buildStatusBanner(BuildContext context) {
    final cfg = resolveBanner();
    if (cfg == null) return const SizedBox.shrink();
    return DetailStatusBanner(config: cfg);
  }
}
