import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_finance_ui.dart';
import '../../shared/mission_shared_widgets.dart';
import '../../shared/mission_status_ui.dart';
import '../primitives/mission_card_frame.dart';
import '../primitives/mission_meta_row.dart';

// ─── Variant : Missions engagées ─────────────────────────────────────────────
// Responsabilité : afficher une mission dont l'utilisateur fait partie
// (postulées, en cours côté freelancer — publiées, en cours côté client).
// Compose MissionCardFrame + MissionMetaRow + MissionStatusChip.
//
// Paramètres de configuration :
//   • role            — détermine le label de statut (freelancer vs client)
//   • showDescription — afficher la description (client : true, freelancer : false)
//   • showAddress     — inclure l'adresse dans les meta pills
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

    final metaItems = [
      MissionMetaItem(
        icon: Icons.calendar_today_outlined,
        text: mission.formattedDate,
      ),
      MissionMetaItem(icon: Icons.schedule_outlined, text: mission.timeSlot),
      if (showAddress)
        MissionMetaItem(
          icon: Icons.location_on_outlined,
          text: mission.address.shortAddress,
        ),
    ];

    return MissionCardFrame(
      onTap: onTap,
      radius: MissionCardFrame.radiusFlat,
      shadows: MissionCardFrame.noShadow,
      border: Border.all(color: context.colors.border),
      child: Padding(
        padding: const EdgeInsets.all(MissionCardFrame.paddingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiérarchie alignée sur les rangées du feed :
            // catégorie en micro-label, titre de mission en vedette.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.categoryName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: context.colors.textTertiary,
                        ),
                      ),
                      AppGap.h4,
                      Text(
                        mission.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                BudgetText(budget: mission.budget),
              ],
            ),
            if (showDescription && mission.description.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mission.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: MissionMetaRow(items: metaItems)),
                const SizedBox(width: 12),
                // Statut : point d'accent + texte, sans pilule
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
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (MissionFinanceStatusBadge.shouldDisplay(mission)) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: MissionFinanceStatusBadge(mission: mission, role: role),
              ),
            ],
            if (extra != null) ...[const SizedBox(height: 12), extra!],
          ],
        ),
      ),
    );
  }
}
