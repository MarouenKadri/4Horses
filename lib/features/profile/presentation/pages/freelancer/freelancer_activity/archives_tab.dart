import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/design/app_design_system.dart';
import '../../../../../mission/presentation/mission_provider.dart';
import '../../../../../mission/presentation/pages/freelancer/freelancer_mission_detail_page.dart';
import '../../../../../mission/presentation/widgets/cards/variants/mission_archive_card.dart';
import '../../../../../mission/presentation/widgets/shared/mission_status_ui.dart';

class FreelancerArchivesTab extends StatelessWidget {
  const FreelancerArchivesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MissionProvider>();
    final missions =
        provider.freelancerMissions
            .where(
              (mission) => MissionStatusUi.belongsToTab(
                status: mission.status,
                role: MissionUiRole.freelancer,
                tab: MissionUiTab.archived,
              ),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (missions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Aucune mission archivée pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      itemCount: missions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final mission = missions[index];
        return MissionArchiveCard(
          mission: mission,
          role: MissionUiRole.freelancer,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  FreelancerMissionDetailPage(mission: mission, isOwn: true),
            ),
          ),
        );
      },
    );
  }
}
