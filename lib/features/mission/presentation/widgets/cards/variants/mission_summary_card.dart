import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_finance_ui.dart';
import '../../shared/mission_status_ui.dart';

// ─── Variant : Missions engagées ─────────────────────────────────────────────
// Responsabilité : afficher une mission dont l'utilisateur fait partie
// (postulées, confirmées, en cours — côté freelancer et client).
// Rangée à plat façon job board, cohérente avec MissionBrowseCard :
// catégorie · titre · ligne budget · exécution · statut. Le séparateur
// entre rangées est fourni par la page (Divider).
//
// Paramètres de configuration :
//   • role            — détermine le label de statut (freelancer vs client)
//   • showDescription — afficher l'extrait de description
//   • showAddress     — inclure l'adresse dans la ligne d'exécution
//   • extra           — slot optionnel Template Method pour ajouts spécifiques
// ─────────────────────────────────────────────────────────────────────────────

class MissionSummaryCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final MissionUiRole role;
  final bool showDescription;
  final bool showAddress;
  final Widget? extra;

  const MissionSummaryCard({
    super.key,
    required this.mission,
    required this.onTap,
    required this.role,
    this.showDescription = false,
    this.showAddress = false,
    this.extra,
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Catégorie ──────────────────────────────────────────────
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
            // ── Titre ──────────────────────────────────────────────────
            Text(
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
            AppGap.h6,
            // ── Ligne budget ───────────────────────────────────────────
            Text(
              mission.budget.detailedLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            if (showDescription && mission.description.trim().isNotEmpty) ...[
              AppGap.h8,
              // ── Extrait description ──────────────────────────────────
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
            // ── Exécution ──────────────────────────────────────────────
            Text(
              scheduleLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
            AppGap.h8,
            // ── Statut : point d'accent + texte, sans pilule ───────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                AppGap.w6,
                Text(
                  statusLabel,
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            if (MissionFinanceStatusBadge.shouldDisplay(mission)) ...[
              AppGap.h10,
              Align(
                alignment: Alignment.centerLeft,
                child: MissionFinanceStatusBadge(mission: mission, role: role),
              ),
            ],
            if (extra != null) ...[AppGap.h12, extra!],
          ],
        ),
      ),
    );
  }
}
