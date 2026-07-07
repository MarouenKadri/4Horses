import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_bar/location_app_bar.dart';
import '../../app/widgets/app_segmented_tab_bar.dart';
import '../../core/design/app_design_system.dart';
import '../client/presentation/pages/freelancer_profile_view.dart';
import '../mission/data/models/mission.dart';
import '../mission/presentation/mission_provider.dart';
import '../mission/presentation/pages/freelancer/mission_browse_page.dart';
import '../story/presentation/widgets/posts_feed.dart';
import '../story/story.dart';

/// Accueil prestataire façon TikTok : le contenu d'abord.
/// Stories en haut, puis le feed de missions directement sous les tabs
/// Particulier | Agence — plus d'écran intermédiaire de navigation.
class FreelancerExploreContent extends StatefulWidget {
  final VoidCallback? onGoToAccount;

  const FreelancerExploreContent({super.key, this.onGoToAccount});

  @override
  State<FreelancerExploreContent> createState() =>
      _FreelancerExploreContentState();
}

class _FreelancerExploreContentState extends State<FreelancerExploreContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isAgency(Mission m) {
    final name = m.client?.name.trim().toLowerCase() ?? '';
    const tokens = [
      'agence',
      'agency',
      'sarl',
      'sas',
      'sasu',
      'eurl',
      'entreprise',
      'societe',
      'société',
      'groupe',
      'holding',
      'studio',
      'cabinet',
      'immobilier',
    ];
    return tokens.any(name.contains);
  }

  @override
  Widget build(BuildContext context) {
    final allMissions = context.watch<MissionProvider>().publicMissions;

    final openMissions = allMissions
        .where(
          (m) =>
              m.status == MissionStatus.waitingCandidates ||
              m.status == MissionStatus.candidateReceived,
        )
        .toList();

    final particulierCount = openMissions.where((m) => !_isAgency(m)).length;
    final agenceCount = openMissions.where(_isAgency).length;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: HomeAppBar(onGoToAccount: widget.onGoToAccount),
      body: SafeArea(
        child: Column(
          children: [
            AppSegmentedTabBar(
              controller: _tabController,
              tabs: [
                const AppSegmentedTab(
                  icon: Icons.grid_view_rounded,
                  label: 'Posts',
                ),
                AppSegmentedTab(
                  icon: Icons.person_outline_rounded,
                  label: particulierCount > 0
                      ? 'Particulier · $particulierCount'
                      : 'Particulier',
                ),
                AppSegmentedTab(
                  icon: Icons.business_outlined,
                  label: agenceCount > 0 ? 'Agence · $agenceCount' : 'Agence',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PostsFeed(
                    onCreateTap: () => pickAndOpenComposer(context),
                    onProfileTap: (group) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FreelancerProfileView(
                          freelancerId: group.groupId,
                          freelancerName: group.groupName,
                          freelancerAvatar: group.avatarUrl,
                        ),
                      ),
                    ),
                  ),
                  const MissionBrowsePage(
                    publisherType: PublisherType.particulier,
                    embedded: true,
                  ),
                  const MissionBrowsePage(
                    publisherType: PublisherType.agence,
                    embedded: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
