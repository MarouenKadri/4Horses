import 'package:flutter/material.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_finance_ui.dart';
import '../../shared/mission_status_ui.dart';
import '../primitives/mission_card_frame.dart';
import '../primitives/mission_status_chip.dart';

// ─── Variant : Archives ───────────────────────────────────────────────────────
// Responsabilité : afficher une mission archivée (layout compact, fond gris).
// Compose MissionCardFrame + MissionStatusChip.archive.
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

    return MissionCardFrame(
      onTap: onTap,
      radius: MissionCardFrame.radiusFlat,
      color: context.colors.surfaceAlt,
      shadows: MissionCardFrame.noShadow,
      child: Padding(
        padding: const EdgeInsets.all(MissionCardFrame.paddingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MissionCardFrame.titleCompactStyle,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _formatDate(mission.date),
                        style: MissionCardFrame.metaStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                MissionStatusChip.archive(context, label: statusLabel),
              ],
            ),
            if (MissionFinanceStatusBadge.shouldDisplay(mission)) ...[
              const SizedBox(height: 10),
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
