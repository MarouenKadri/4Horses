import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_finance_ui.dart';
import '../../shared/mission_status_ui.dart';
import '../../shared/mission_shared_widgets.dart';
import '../primitives/mission_card_frame.dart';
import '../primitives/mission_meta_row.dart';
import '../primitives/mission_status_chip.dart';

// ─── Variant : Focus client home ────────────────────────────────────────────
// Responsabilité : mettre en avant la prochaine mission suivable du client
// sur la home, avec un design plus éditorial mais basé sur les primitives
// des cards mission existantes.
// Compose MissionCardFrame + MissionMetaRow + MissionStatusChip.
// ─────────────────────────────────────────────────────────────────────────────

class MissionFocusCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;

  const MissionFocusCard({
    super.key,
    required this.mission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = MissionStatusUi.badgeLabel(
      status: mission.status,
      role: MissionUiRole.client,
    );

    final metaItems = [
      MissionMetaItem(
        icon: Icons.calendar_today_outlined,
        text: mission.formattedDate,
      ),
      if (mission.timeSlot.isNotEmpty)
        MissionMetaItem(icon: Icons.schedule_outlined, text: mission.timeSlot),
      if (mission.address.shortAddress.isNotEmpty)
        MissionMetaItem(
          icon: Icons.location_on_outlined,
          text: mission.address.shortAddress,
        ),
    ];

    return MissionCardFrame(
      onTap: onTap,
      radius: MissionCardFrame.radiusLarge,
      color: context.colors.surface,
      shadows: MissionCardFrame.defaultShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(MissionCardFrame.radiusLarge),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  mission.status.color.withValues(alpha: 0.95),
                  context.colors.primary.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(MissionCardFrame.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: mission.status.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        mission.status.icon,
                        size: 22,
                        color: mission.status.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Votre prochaine mission',
                            style: MissionCardFrame.metaStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: MissionCardFrame.titleStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    MissionStatusChip.summary(context, label: statusLabel),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Commence ${mission.formattedDate.toLowerCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MissionCardFrame.captionStyle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      BudgetText(budget: mission.budget),
                    ],
                  ),
                ),
                if (metaItems.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  MissionMetaRow(items: metaItems),
                ],
                if (MissionFinanceStatusBadge.shouldDisplay(mission)) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: MissionFinanceStatusBadge(
                      mission: mission,
                      role: MissionUiRole.client,
                    ),
                  ),
                ],
                if (mission.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    mission.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MissionCardFrame.subtitleStyle,
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
