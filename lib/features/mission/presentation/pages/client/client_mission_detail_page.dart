import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/detail/mission_detail_primitives.dart';
import '../../widgets/detail/mission_detail_template.dart';
import '../../widgets/shared/mission_finance_ui.dart';
import '../../../../client/presentation/pages/freelancer_profile_view.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';
import '../../../../messaging/messaging_provider.dart';
import 'candidates_page.dart';
import '../../widgets/detail/client_detail_sections.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/shared/mission_status_ui.dart';
import 'create_mission_page.dart';
import 'mission_validation_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ClientMissionDetailPage — rôle client
/// Extends MissionDetailBase (Template Method) + délègue les sections à
/// client_detail_sections.dart
/// ═══════════════════════════════════════════════════════════════════════════

class ClientMissionDetailPage extends StatefulWidget {
  final Mission mission;
  final Function(PrestaInfo)? onCandidateAccepted;

  const ClientMissionDetailPage({
    super.key,
    required this.mission,
    this.onCandidateAccepted,
  });

  @override
  State<ClientMissionDetailPage> createState() =>
      _ClientMissionDetailPageState();
}

class _ClientMissionDetailPageState
    extends MissionDetailBase<ClientMissionDetailPage> {

  // ─── Computed flags ─────────────────────────────────────────────────────────

  bool get canModify =>
      mission.status == MissionStatus.waitingCandidates ||
      mission.status == MissionStatus.candidateReceived ||
      mission.status == MissionStatus.draft;

  bool get canCancel =>
      mission.status == MissionStatus.waitingCandidates ||
      mission.status == MissionStatus.candidateReceived ||
      mission.status == MissionStatus.pendingAcceptance ||
      mission.status == MissionStatus.confirmed ||
      mission.status == MissionStatus.draft;

  // ─── MissionDetailBase — abstract overrides ──────────────────────────────

  @override
  Mission get widgetMission => widget.mission;

  @override
  Mission syncMission(BuildContext ctx) {
    return ctx.watch<MissionProvider>().clientMissions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => mission,
    );
  }

  @override
  bool get canSeeFullAddress => true;

  @override
  bool get showTimeline => mission.status != MissionStatus.draft;

  @override
  bool get isBottomHidden => mission.status == MissionStatus.closed;

  @override
  Widget? buildHeroMenu(BuildContext ctx) {
    if (!canModify && !canCancel) return null;
    return DetailHeroBtn(
      icon: Icons.more_horiz_rounded,
      onTap: _showMissionOptions,
    );
  }

  @override
  Widget buildTagsPrice(BuildContext ctx) {
    final daysLeft = mission.date.difference(DateTime.now()).inDays;
    final daysLabel = daysLeft > 0 ? '+$daysLeft jours' : "Aujourd'hui";
    final hasAssignedPresta = mission.assignedPresta != null;

    // Texte simple plutôt que pilules — même doctrine que le header profil.
    final infoLabel = [
      daysLabel,
      if (!hasAssignedPresta)
        '${mission.candidatesCount} candidat${mission.candidatesCount > 1 ? 's' : ''}',
    ].join(' · ');

    return Row(
      children: [
        Expanded(
          child: Text(
            infoLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ctx.text.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: ctx.colors.textSecondary,
            ),
          ),
        ),
        AppGap.w12,
        BudgetText(budget: mission.budget, large: true),
      ],
    );
  }

  @override
  Widget? buildFinanceExposureCard(BuildContext ctx) {
    if (!MissionFinanceExposureCard.shouldDisplay(mission)) return null;
    return MissionFinanceExposureCard(
      mission: mission,
      role: MissionUiRole.client,
    );
  }

  @override
  StatusBannerConfig? resolveBanner() {
    switch (mission.status) {
      case MissionStatus.pendingAcceptance:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          title: mission.assignedPresta != null
              ? 'En attente de ${mission.assignedPresta!.name}'
              : 'En attente du prestataire',
          subtitle:
              'Votre réservation a été envoyée. La mission sera confirmée dès que le prestataire l\'accepte.',
        );
      case MissionStatus.onTheWay:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.directions_car_rounded,
          title: mission.assignedPresta != null
              ? '${mission.assignedPresta!.name} est en route'
              : 'Votre prestataire est en route',
          subtitle:
              'Suivez son arrivée en temps réel depuis l\'onglet Missions.',
        );
      case MissionStatus.inProgress:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.handyman_rounded,
          title: 'Mission en cours',
          subtitle: mission.assignedPresta != null
              ? '${mission.assignedPresta!.name} est actuellement sur place.'
              : 'Le prestataire est actuellement sur place.',
          pulse: true,
        );
      case MissionStatus.completionRequested:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          title: 'Le prestataire a signale la fin',
          subtitle:
              'Confirmez la mission ou signalez un problème pour bloquer le paiement.',
        );
      case MissionStatus.paymentHeld:
        return StatusBannerConfig(
          color: AppColors.success,
          icon: Icons.shield_rounded,
          title: 'Paiement sécurisé',
          subtitle:
              'Les fonds ont bien été reçus et seront conservés jusqu\'à confirmation du service.',
        );
      case MissionStatus.completed:
      case MissionStatus.awaitingRelease:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.schedule_rounded,
          title: 'Livraison effectuée — 24h pour signaler un problème',
          subtitle:
              'Sans retour de votre part, le paiement sera versé automatiquement au prestataire dans 24h.',
        );
      case MissionStatus.inDispute:
        return StatusBannerConfig(
          color: AppColors.error,
          icon: Icons.flag_rounded,
          title: 'Litige en cours — paiement suspendu',
          subtitle:
              'Votre signalement est en cours de vérification. Aucun versement ne sera effectué pendant ce délai.',
        );
      case MissionStatus.closed:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.check_circle_outline_rounded,
          title: 'Mission terminée',
          subtitle:
              'Le paiement a été versé au prestataire et la mission est maintenant clôturée.',
        );
      case MissionStatus.cancelled:
        return StatusBannerConfig(
          color: AppColors.error,
          icon: Icons.close_rounded,
          title: 'Mission annulée',
          subtitle:
              "Cette mission est clôturée et aucune action supplémentaire n'est requise.",
        );
      default:
        return null;
    }
  }

  @override
  Widget buildRoleSection(BuildContext ctx) {
    if (mission.status == MissionStatus.candidateReceived ||
        mission.status == MissionStatus.waitingCandidates) {
      return ClientCandidatesCard(
        count: mission.candidatesCount,
        onViewCandidates: _openCandidates,
      );
    }
    if (mission.assignedPresta != null) {
      final presta = mission.assignedPresta!;
      final contactable =
          mission.status != MissionStatus.awaitingRelease &&
          mission.status != MissionStatus.closed;
      return Column(
        children: [
          ClientPrestaCard(
            presta: presta,
            status: mission.status,
            rating: mission.rating,
            onPhone: contactable ? () => _openPhone(presta) : null,
            onChat: contactable ? () => _openChat(presta) : null,
            onViewProfile: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => FreelancerProfileView(
                  freelancerId: presta.id,
                  freelancerName: presta.name,
                  freelancerAvatar: presta.avatarUrl,
                  rating: presta.rating,
                  reviewsCount: presta.reviewsCount,
                  missionsCount: presta.completedMissions,
                  contactMode: FreelancerContactMode.confirmedPresta,
                  confirmedMissionTitle: mission.title,
                ),
              ),
            ),
          ),
          if (mission.status == MissionStatus.completionRequested)
            ClientCompletionRequestedCard(
              mission: mission,
              onConfirm: _openValidationScreen,
              onDispute: _openCompletionDispute,
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget buildBottom(BuildContext ctx) {
    if (mission.status == MissionStatus.awaitingRelease) {
      return DetailBottomArea(
        child: DetailTealButton(
          label: 'Valider et libérer le paiement',
          icon: Icons.check_circle_rounded,
          onTap: _openValidationScreen,
        ),
      );
    }

    if (mission.status == MissionStatus.completionRequested) {
      return DetailBottomArea(
        caption: 'Le prestataire a demande la cloture de la mission',
        child: DetailTealButton(
          label: 'Verifier et confirmer la mission',
          icon: Icons.verified_rounded,
          onTap: _openValidationScreen,
        ),
      );
    }

    if (mission.status == MissionStatus.candidateReceived) {
      return DetailBottomArea(
        caption: 'Choisissez votre prestataire',
        child: DetailTealButton(
          label:
              'Voir les ${mission.candidatesCount} candidat${mission.candidatesCount > 1 ? 's' : ''}',
          icon: Icons.people_alt_rounded,
          onTap: _openCandidates,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _showMissionOptions() async {
    await showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: ClientActionSheet(
        canModify: canModify,
        canCancel: canCancel,
        onEdit: () {
          Navigator.pop(context);
          _editMission();
        },
        onShare: () {
          Navigator.pop(context);
          _shareMission();
        },
        onCancel: () {
          Navigator.pop(context);
          _showCancelDialog();
        },
      ),
    );
  }

  Future<void> _openPhone(PrestaInfo presta) async {
    final phone = presta.phone;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareMission() async {
    final shareText = [
      mission.title,
      mission.address.fullAddress,
      '${mission.formattedDate} · ${mission.timeSlot}',
      'Budget: ${mission.budget.displayText}',
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    showAppSnackBar(
      context,
      'Details de la mission copies',
      icon: Icons.share_outlined,
      duration: const Duration(seconds: 2),
    );
  }

  void _openCandidates() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CandidatesPage(
        missionId: mission.id,
        missionTitle: mission.title,
        missionBudget: mission.budget.displayText,
      ),
    ),
  );

  Future<void> _openValidationScreen() async => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MissionValidationPage(mission: mission)),
  );

  Future<void> _openChat(PrestaInfo presta) async {
    final conversationId = await context
        .read<MessagingProvider>()
        .getOrCreateConversation(
          otherUserId: presta.id,
          iAmClient: true,
          missionId: mission.id,
        );
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          conversationId: conversationId,
          contactUserId: presta.id,
          contactName: presta.name,
          contactAvatar: presta.avatarUrl,
          isVerified: presta.isVerified,
          missionTitle: mission.title,
          missionId: mission.id,
          isMissionConfirmed: const {
            MissionStatus.confirmed,
            MissionStatus.onTheWay,
            MissionStatus.inProgress,
            MissionStatus.completionRequested,
            MissionStatus.completed,
            MissionStatus.paymentHeld,
            MissionStatus.awaitingRelease,
            MissionStatus.closed,
          }.contains(mission.status),
        ),
      ),
    );
  }

  Future<void> _editMission() async => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => PostMissionFlow(mission: mission)),
  );

  void _showCancelDialog() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: ClientCancelSheet(
        missionTitle: mission.title,
        missionStart: mission.scheduledStart,
        missionAmount: mission.budget.averageAmount,
        onConfirm: () {
          context.read<MissionProvider>().updateMissionStatus(
            mission.id,
            MissionStatus.cancelled,
          );
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openCompletionDispute() {
    showAppDialog(
      context: context,
      title: const Text('Signaler un problème'),
      content: const Text(
        'Le paiement restera bloque pendant l analyse du litige par l equipe support.',
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Signaler',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        context.read<MissionProvider>().updateMissionStatus(
          mission.id,
          MissionStatus.inDispute,
        );
        Navigator.pop(context);
      },
    );
  }
}
