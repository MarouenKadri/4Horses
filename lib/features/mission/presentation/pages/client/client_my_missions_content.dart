import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/shared/mission_status_ui.dart';
import '../../widgets/cards/variants/mission_summary_card.dart';
import 'client_mission_detail_page.dart';
import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📋 Inkern - Page Mes Missions (Client)
/// Tabs : Publiées · En cours
/// ═══════════════════════════════════════════════════════════════════════════

class ClientMyMissionsContent extends StatelessWidget {
  final VoidCallback? onGoToAccount;
  const ClientMyMissionsContent({super.key, this.onGoToAccount});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppSectionBar(
          pageTitle: 'Mes missions',
          onGoToAccount: onGoToAccount,
          bottom: const AppSegmentedTabBar(
            tabs: [
              AppSegmentedTab(icon: Icons.campaign_rounded, label: 'Publiées'),
              AppSegmentedTab(
                icon: Icons.check_circle_outline_rounded,
                label: 'Confirmées',
              ),
              AppSegmentedTab(
                icon: Icons.play_circle_outline_rounded,
                label: 'En cours',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ClientMissionTab(filter: _ClientTabFilter.published),
            _ClientMissionTab(filter: _ClientTabFilter.confirmed),
            _ClientMissionTab(filter: _ClientTabFilter.inProgress),
          ],
        ),
      ),
    );
  }
}

enum _ClientTabFilter { published, confirmed, inProgress }

extension _ClientTabFilterX on _ClientTabFilter {
  MissionUiTab get uiTab => switch (this) {
    _ClientTabFilter.published  => MissionUiTab.published,
    _ClientTabFilter.confirmed  => MissionUiTab.confirmed,
    _ClientTabFilter.inProgress => MissionUiTab.inProgress,
  };
}

class _ClientMissionTab extends StatefulWidget {
  final _ClientTabFilter filter;
  const _ClientMissionTab({required this.filter});

  @override
  State<_ClientMissionTab> createState() => _ClientMissionTabState();
}

class _ClientMissionTabState extends State<_ClientMissionTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<Mission> _filter(List<Mission> all) {
    return all.where((m) => MissionStatusUi.missionBelongsToTab(
      mission: m,
      role: MissionUiRole.client,
      tab: widget.filter.uiTab,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SkeletonList(key: ValueKey('skeleton'));

    final missions = _filter(context.watch<MissionProvider>().clientMissions);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: missions.isEmpty
          ? EmptyState(
              key: const ValueKey('empty'),
              icon: _emptyIcon,
              title: _emptyTitle,
              subtitle: _emptySubtitle,
            )
          : ListView.builder(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: missions.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: MissionSummaryCard(
                  mission: missions[index],
                  role: MissionUiRole.client,
                  showDescription: true,
                  showAddress: true,
                  onTap: () => Navigator.push(
                    context,
                    slideUpRoute(page: ClientMissionDetailPage(mission: missions[index])),
                  ),
                  extra: widget.filter == _ClientTabFilter.published
                      ? _CandidatesBadge(count: missions[index].candidatesCount)
                      : null,

                ),
              ),
            ),
    );
  }

  IconData get _emptyIcon => switch (widget.filter) {
    _ClientTabFilter.published  => Icons.assignment_outlined,
    _ClientTabFilter.confirmed  => Icons.check_circle_outline_rounded,
    _ClientTabFilter.inProgress => Icons.work_outline_rounded,
  };

  String get _emptyTitle => switch (widget.filter) {
    _ClientTabFilter.published  => 'Aucune mission publiée',
    _ClientTabFilter.confirmed  => 'Aucune mission confirmée',
    _ClientTabFilter.inProgress => 'Aucune mission en cours',
  };

  String get _emptySubtitle => switch (widget.filter) {
    _ClientTabFilter.published  => 'Créez une mission pour trouver un prestataire',
    _ClientTabFilter.confirmed  => 'Les missions avec un prestataire choisi apparaîtront ici',
    _ClientTabFilter.inProgress => 'Vos missions du jour apparaîtront ici',
  };
}

class _CandidatesBadge extends StatelessWidget {
  final int count;
  const _CandidatesBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final hasOffers = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: hasOffers
            ? context.colors.primary.withValues(alpha: 0.08)
            : context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: hasOffers
              ? context.colors.primary.withValues(alpha: 0.25)
              : context.colors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasOffers ? Icons.people_alt_rounded : Icons.hourglass_empty_rounded,
            size: 14,
            color: hasOffers ? context.colors.primary : context.colors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            hasOffers
                ? '$count offre${count > 1 ? 's' : ''} reçue${count > 1 ? 's' : ''}'
                : 'Aucune offre pour l\'instant',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasOffers ? context.colors.primary : context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

