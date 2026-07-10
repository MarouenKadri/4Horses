import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_finance_ui.dart';
import '../../shared/mission_status_ui.dart';

// ─── Variant : Archives ───────────────────────────────────────────────────────
// Responsabilité : afficher une mission archivée — rangée à plat compacte,
// entièrement grisée (l'historique ne rivalise pas avec l'actif).
// Le séparateur entre rangées est fourni par la page (Divider).
//
// Le rôle est résolu par la PAGE (ArchivesPage) et passé en paramètre —
// cette card ne dépend pas de AuthProvider.
// ─────────────────────────────────────────────────────────────────────────────

class MissionArchiveCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final MissionUiRole role;

  const MissionArchiveCard({
    super.key,
    required this.mission,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = MissionStatusUi.badgeLabel(
      status: mission.status,
      role: role,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    mission.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                AppGap.w12,
                Text(
                  _formatDate(mission.date),
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
            AppGap.h6,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: context.colors.textHint,
                    shape: BoxShape.circle,
                  ),
                ),
                AppGap.w6,
                Text(
                  statusLabel,
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
            ),
            if (MissionFinanceStatusBadge.shouldDisplay(mission)) ...[
              AppGap.h8,
              Align(
                alignment: Alignment.centerLeft,
                child: MissionFinanceStatusBadge(mission: mission, role: role),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
