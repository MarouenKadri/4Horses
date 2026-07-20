import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_finance_ui.dart';
import '../../shared/mission_shared_widgets.dart';
import '../../shared/mission_status_ui.dart';

// ─── Variant : Missions engagées ─────────────────────────────────────────────
// Responsabilité : afficher une mission dont l'utilisateur fait partie
// (postulées, confirmées, en cours — côté freelancer et client).
// Rangée à plat façon job board, cohérente avec MissionBrowseCard :
// catégorie · titre · ligne budget · exécution · statut. Le séparateur
// entre rangées est fourni par la page (Divider).
//
// Paramètres de configuration :
//   • role              — détermine le label de statut (freelancer vs client)
//   • showDescription   — afficher l'extrait de description
//   • showAddress       — inclure l'adresse dans la ligne d'exécution
//   • extra             — slot optionnel Template Method pour ajouts spécifiques
//   • live              — variant "en cours" : avatar contact, icône de statut
//                          colorée et chevron d'ouverture (au lieu du point neutre)
//   • showThumbnail     — vignette mission à gauche (ex. onglet "Publiées")
//   • showDateHighlight — pavé date/heure mis en avant (ex. onglet "Confirmées")
// ─────────────────────────────────────────────────────────────────────────────

class MissionSummaryCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final MissionUiRole role;
  final bool showDescription;
  final bool showAddress;
  final Widget? extra;

  /// Action texte discrète alignée à droite de la ligne de statut
  /// (ex. « Retirer ma candidature »)
  final Widget? statusTrailing;

  /// Active le rendu enrichi pour les missions actives (avatar du contact,
  /// icône de statut colorée, chevron) — pensé pour l'onglet "En cours".
  final bool live;

  /// Vignette de la mission (première photo) à gauche du contenu.
  final bool showThumbnail;

  /// Pavé date/heure mis en avant à droite (jour + heure sur deux lignes)
  /// au lieu de la simple ligne d'exécution grise.
  final bool showDateHighlight;

  const MissionSummaryCard({
    super.key,
    required this.mission,
    required this.onTap,
    required this.role,
    this.showDescription = false,
    this.showAddress = false,
    this.extra,
    this.statusTrailing,
    this.live = false,
    this.showThumbnail = false,
    this.showDateHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = MissionStatusUi.badgeLabel(
      status: mission.status,
      role: role,
    );

    final scheduleLine = [
      mission.formattedDate,
      mission.timeSlot,
      if (showAddress) mission.address.shortAddress,
    ].join(' · ');

    final contactName = role == MissionUiRole.freelancer
        ? mission.client?.name
        : mission.assignedPresta?.name;
    final contactAvatar = role == MissionUiRole.freelancer
        ? mission.client?.avatarUrl
        : mission.assignedPresta?.avatarUrl;
    final contactVerified = role == MissionUiRole.freelancer
        ? (mission.client?.isVerified ?? false)
        : (mission.assignedPresta?.isVerified ?? false);

    final isToday = mission.formattedDate == 'Aujourd\'hui';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (live) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: UserAvatar(
                  imageUrl: contactAvatar ?? '',
                  radius: 22,
                  showVerified: contactVerified,
                ),
              ),
              AppGap.w12,
            ] else if (showThumbnail) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: mission.images.isNotEmpty
                      ? Image.network(
                          mission.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: context.colors.surfaceAlt,
                            child: Icon(
                              mission.categoryIcon,
                              size: 22,
                              color: context.colors.textTertiary,
                            ),
                          ),
                        )
                      : ColoredBox(
                          color: context.colors.surfaceAlt,
                          child: Icon(
                            mission.categoryIcon,
                            size: 22,
                            color: context.colors.textTertiary,
                          ),
                        ),
                ),
              ),
              AppGap.w12,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Catégorie ──────────────────────────────────────
                  Text(
                    mission.categoryName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: context.colors.textTertiary,
                    ),
                  ),
                  AppGap.h6,
                  // ── Titre ──────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          mission.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            fontSize: AppFontSize.body,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (live && isToday) ...[
                        AppGap.w8,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Aujourd\'hui',
                            style: context.text.labelSmall?.copyWith(
                              fontSize: AppFontSize.tiny,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (live && contactName != null) ...[
                    AppGap.h2,
                    Text(
                      contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  AppGap.h6,
                  // ── Ligne budget ─────────────────────────────────────
                  Text(
                    mission.budget.detailedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (showDescription &&
                      mission.description.trim().isNotEmpty) ...[
                    AppGap.h8,
                    // ── Extrait description ────────────────────────────
                    Text(
                      mission.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                  AppGap.h10,
                  // ── Exécution ────────────────────────────────────────
                  if (showDateHighlight)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 14,
                            color: context.colors.textSecondary,
                          ),
                          AppGap.w6,
                          Text(
                            mission.formattedDate,
                            style: context.text.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          if (mission.timeSlot.isNotEmpty) ...[
                            AppGap.w4,
                            Text(
                              '· ${mission.timeSlot}',
                              style: context.text.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    Text(
                      scheduleLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  AppGap.h8,
                  // ── Statut ────────────────────────────────────────────
                  Row(
                    children: [
                      if (live) ...[
                        Icon(
                          mission.status.icon,
                          size: 14,
                          color: mission.status.color,
                        ),
                        AppGap.w6,
                      ] else ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppGap.w6,
                      ],
                      Expanded(
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: live
                                ? mission.status.color
                                : context.colors.textSecondary,
                          ),
                        ),
                      ),
                      if (statusTrailing != null) ...[
                        AppGap.w12,
                        statusTrailing!,
                      ],
                    ],
                  ),
                  if (MissionFinanceStatusBadge.shouldDisplay(mission)) ...[
                    AppGap.h10,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: MissionFinanceStatusBadge(
                        mission: mission,
                        role: role,
                      ),
                    ),
                  ],
                  if (extra != null) ...[AppGap.h12, extra!],
                ],
              ),
            ),
            if (live) ...[
              AppGap.w8,
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
