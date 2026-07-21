import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth_provider.dart';
import '../../enum/user_role.dart';
import '../../../features/client/presentation/pages/client_discover_content.dart';
import '../../../features/freelancer/freelancer_explore_content.dart';

/// Routeur rôle-aware pour l'onglet Découvrir / Explorer.
/// Délègue à [ClientDiscoverContent] ou [FreelancerExploreContent]
/// selon le rôle actif — sans logique UI propre.
class DiscoverShell extends StatelessWidget {
  final VoidCallback? onGoToAccount;

  const DiscoverShell({super.key, this.onGoToAccount});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentRole;

    return switch (role) {
      UserRole.client   => ClientDiscoverContent(onGoToAccount: onGoToAccount),
      UserRole.provider => FreelancerExploreContent(onGoToAccount: onGoToAccount),
      _                 => const SizedBox.shrink(),
    };
  }
}
