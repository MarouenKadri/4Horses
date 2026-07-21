import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth_provider.dart';
import '../../enum/user_role.dart';
import '../../../features/mission/presentation/pages/client/client_my_missions_content.dart';
import '../../../features/mission/presentation/pages/freelancer/freelancer_engagements_content.dart';

/// Routeur rôle-aware pour l'onglet Missions.
/// Délègue à [ClientMyMissionsContent] ou [FreelancerEngagementsContent]
/// selon le rôle actif — sans logique UI propre.
class MissionsShell extends StatelessWidget {
  final VoidCallback? onGoToAccount;

  const MissionsShell({super.key, this.onGoToAccount});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentRole;

    return switch (role) {
      UserRole.client   => ClientMyMissionsContent(onGoToAccount: onGoToAccount),
      UserRole.provider => FreelancerEngagementsContent(onGoToAccount: onGoToAccount),
      _                 => const SizedBox.shrink(),
    };
  }
}
