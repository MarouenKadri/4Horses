import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../../app/widgets/app_segmented_tab_bar.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/shared/mission_status_ui.dart';
import '../../widgets/cards/variants/mission_summary_card.dart';
import 'freelancer_mission_detail_page.dart';
import 'freelancer_tracking_page.dart';
import '../../../../messaging/messaging_provider.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';

class FreelancerEngagementsContent extends StatelessWidget {
  final VoidCallback? onGoToAccount;

  const FreelancerEngagementsContent({super.key, this.onGoToAccount});

  @override
  Widget build(BuildContext context) {
    final hasInProgress = context
        .watch<MissionProvider>()
        .freelancerMissions
        .any(
          (m) => MissionStatusUi.missionBelongsToTab(
            mission: m,
            role: MissionUiRole.freelancer,
            tab: MissionUiTab.inProgress,
          ),
        );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppSectionBar(
          pageTitle: 'Mes missions',
          onGoToAccount: onGoToAccount,
        ),
        body: Column(
          children: [
            AppSegmentedTabBar(
              tabs: [
                const AppSegmentedTab(
                  icon: Icons.send_rounded,
                  label: 'Postulées',
                ),
                const AppSegmentedTab(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Confirmées',
                ),
                AppSegmentedTab(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'En cours',
                  alert: hasInProgress,
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _MissionTab(filter: _TabFilter.applied),
                  _MissionTab(filter: _TabFilter.confirmed),
                  _MissionTab(filter: _TabFilter.inProgress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TabFilter { applied, confirmed, inProgress }

extension _TabFilterX on _TabFilter {
  MissionUiTab get uiTab => switch (this) {
    _TabFilter.applied => MissionUiTab.applied,
    _TabFilter.confirmed => MissionUiTab.confirmed,
    _TabFilter.inProgress => MissionUiTab.inProgress,
  };
}

class _MissionTab extends StatefulWidget {
  final _TabFilter filter;

  const _MissionTab({required this.filter});

  @override
  State<_MissionTab> createState() => _MissionTabState();
}

class _MissionTabState extends State<_MissionTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _confirmWithdraw(BuildContext context, Mission mission) async {
    final provider = context.read<MissionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: const Text('Retirer la candidature'),
      content: Text(
        'Voulez-vous retirer votre candidature pour "${mission.title}" ?',
      ),
      confirmLabel: 'Retirer',
      cancelLabel: 'Annuler',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    try {
      await provider.withdrawCandidacy(mission.id);
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'Candidature retirée',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Erreur lors du retrait',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openTracking(Mission mission) {
    final client = mission.client;
    final contactable =
        client != null &&
        mission.status != MissionStatus.awaitingRelease &&
        mission.status != MissionStatus.closed;
    Navigator.push(
      context,
      slideUpRoute(
        page: FreelancerTrackingPage(
          mission: mission,
          onCall: contactable ? () => _openPhoneClient(client) : null,
          onChat: contactable ? () => _openChat(mission, client) : null,
        ),
      ),
    );
  }

  Future<void> _openPhoneClient(ClientInfo client) async {
    final phone = client.phone;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openChat(Mission mission, ClientInfo client) async {
    final conversationId = await context
        .read<MessagingProvider>()
        .getOrCreateConversation(
          otherUserId: client.id,
          iAmClient: false,
          missionId: mission.id,
        );
    if (!mounted) return;
    if (conversationId == null) {
      showAppSnackBar(
        context,
        'Impossible d\'ouvrir la conversation. Réessayez.',
        icon: Icons.error_outline_rounded,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: conversationId,
          contactUserId: client.id,
          contactName: client.name,
          contactAvatar: client.avatarUrl,
          isVerified: client.isVerified,
          missionTitle: mission.title,
          missionId: mission.id,
          confirmedMissionTitle: mission.title,
          isMissionConfirmed: true,
        ),
      ),
    );
  }

  List<Mission> _filter(List<Mission> all) {
    return all
        .where(
          (m) => MissionStatusUi.missionBelongsToTab(
            mission: m,
            role: MissionUiRole.freelancer,
            tab: widget.filter.uiTab,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SkeletonList(key: ValueKey('skeleton'));
    }

    final missions = _filter(
      context.watch<MissionProvider>().freelancerMissions,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: missions.isEmpty
          ? EmptyState(
              key: const ValueKey('empty'),
              icon: _emptyIcon,
              title: _emptyTitle,
              subtitle: _emptySubtitle,
            )
          : ListView.separated(
              key: const ValueKey('list'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: missions.length,
              separatorBuilder: (context, _) =>
                  Divider(height: 1, color: context.colors.divider),
              itemBuilder: (context, index) {
                final mission = missions[index];
                final canWithdraw =
                    widget.filter == _TabFilter.applied &&
                    (mission.status == MissionStatus.waitingCandidates ||
                        mission.status == MissionStatus.candidateReceived);
                final isConfirmedTab = widget.filter == _TabFilter.confirmed;
                final isInProgressTab = widget.filter == _TabFilter.inProgress;

                return MissionSummaryCard(
                  mission: mission,
                  role: MissionUiRole.freelancer,
                  showDescription: false,
                  live: isInProgressTab,
                  showDateHighlight: isConfirmedTab,
                  onTap: () => isInProgressTab
                      ? _openTracking(mission)
                      : Navigator.push(
                          context,
                          slideUpRoute(
                            page: FreelancerMissionDetailPage(
                              mission: mission,
                              isOwn: true,
                            ),
                          ),
                        ),
                  statusTrailing: canWithdraw
                      ? InkWell(
                          onTap: () => _confirmWithdraw(context, mission),
                          child: Text(
                            'Retirer ma candidature',
                            style: context.text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.error,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
    );
  }

  IconData get _emptyIcon => switch (widget.filter) {
    _TabFilter.applied => Icons.send_outlined,
    _TabFilter.confirmed => Icons.check_circle_outline_rounded,
    _TabFilter.inProgress => Icons.work_outline_rounded,
  };

  String get _emptyTitle => switch (widget.filter) {
    _TabFilter.applied => 'Aucune candidature',
    _TabFilter.confirmed => 'Aucune mission confirmée',
    _TabFilter.inProgress => 'Aucune mission en cours',
  };

  String get _emptySubtitle => switch (widget.filter) {
    _TabFilter.applied => 'Explorez les missions disponibles et postulez',
    _TabFilter.confirmed =>
      'Les missions où vous avez été sélectionné apparaîtront ici',
    _TabFilter.inProgress => 'Vos missions du jour apparaîtront ici',
  };
}
