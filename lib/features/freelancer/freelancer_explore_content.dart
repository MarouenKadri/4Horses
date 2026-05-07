import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_bar/location_app_bar.dart';
import '../../core/design/app_design_system.dart';
import '../../core/design/tokens/app_colors.dart';
import '../../features/profile/profile_provider.dart';
import '../client/presentation/pages/freelancer_profile_view.dart';
import '../mission/data/models/mission.dart';
import '../mission/presentation/mission_provider.dart';
import '../mission/presentation/pages/freelancer/mission_browse_page.dart';
import '../story/presentation/widgets/stories_section.dart';
import '../story/story.dart';

class FreelancerExploreContent extends StatefulWidget {
  final VoidCallback? onGoToAccount;

  const FreelancerExploreContent({super.key, this.onGoToAccount});

  @override
  State<FreelancerExploreContent> createState() => _FreelancerExploreContentState();
}

class _FreelancerExploreContentState extends State<FreelancerExploreContent> {
  LocationData? _selectedLocation;

  Future<void> _pickLocation() async {
    final address = context.read<ProfileProvider>().profile?.address;
    final result = await HomeAppBarCoordinator.pickLocation(
      context,
      currentAddress: address,
      selectedLocation: _selectedLocation,
    );
    if (result != null) setState(() => _selectedLocation = result);
  }

  String get _locationLabel {
    if (_selectedLocation != null) return _selectedLocation!.label;
    final address = context.read<ProfileProvider>().profile?.address;
    return HomeAppBarCoordinator.parseCity(address);
  }

  @override
  Widget build(BuildContext context) {
    final allMissions = context.watch<MissionProvider>().publicMissions;
    final storyGroups = context.watch<StoryProvider>().storyGroups;

    final openMissions = allMissions.where((m) =>
        m.status == MissionStatus.waitingCandidates ||
        m.status == MissionStatus.candidateReceived).toList();

    bool isAgency(Mission m) {
      final name = m.client?.name.trim().toLowerCase() ?? '';
      const tokens = [
        'agence', 'agency', 'sarl', 'sas', 'sasu', 'eurl',
        'entreprise', 'societe', 'société', 'groupe', 'holding',
        'studio', 'cabinet', 'immobilier',
      ];
      return tokens.any(name.contains);
    }

    final particulierCount = openMissions.where((m) => !isAgency(m)).length;
    final agenceCount = openMissions.where((m) => isAgency(m)).length;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: HomeAppBar(onGoToAccount: widget.onGoToAccount),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: StoriesSection(
                storyGroups: storyGroups,
                isFreelancer: true,
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
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _LocationChip(
                    label: _locationLabel,
                    onTap: _pickLocation,
                  ),
                  const SizedBox(height: 16),
                  _ExploreCard(
                    icon: Icons.person_rounded,
                    title: 'Particulier',
                    subtitle: 'Missions publiées par des particuliers',
                    count: particulierCount,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MissionBrowsePage(
                          publisherType: PublisherType.particulier,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ExploreCard(
                    icon: Icons.business_rounded,
                    title: 'Agence',
                    subtitle: 'Missions publiées par des agences & entreprises',
                    count: agenceCount,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MissionBrowsePage(
                          publisherType: PublisherType.agence,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LocationChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Où chercher ?',
          style: context.text.labelSmall?.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppColors.inkDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.inkDark.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: AppColors.inkDark),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.inkDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count mission${count > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.inkDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
