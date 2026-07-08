import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../../messaging/messaging_provider.dart';
import '../../../../messaging/presentation/pages/chat_page.dart';
import '../../../../reviews/presentation/pages/client_review_page.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/detail/mission_detail_primitives.dart';
import '../../widgets/detail/mission_detail_template.dart';
import '../../widgets/shared/mission_finance_ui.dart';
import '../../widgets/shared/mission_status_ui.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/detail/freelancer_detail_sections.dart';
import '../../../../profile/presentation/pages/freelancer/freelancer_activity_page.dart';
import 'freelancer_tracking_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FreelancerMissionDetailPage — rôle freelancer
/// Extends MissionDetailBase (Template Method) + délègue les sections à
/// freelancer_detail_sections.dart
/// ═══════════════════════════════════════════════════════════════════════════

class FreelancerMissionDetailPage extends StatefulWidget {
  final Mission mission;

  /// true = mission du freelancer (postulée / en cours / archivée)
  /// false = mission publique depuis l'explorer → peut postuler
  final bool isOwn;

  const FreelancerMissionDetailPage({
    super.key,
    required this.mission,
    this.isOwn = false,
  });

  @override
  State<FreelancerMissionDetailPage> createState() =>
      _FreelancerMissionDetailPageState();
}

class _FreelancerMissionDetailPageState
    extends MissionDetailBase<FreelancerMissionDetailPage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _hasRatedClient = false;

  // ─── Computed flags ─────────────────────────────────────────────────────────

  bool get _isAccepted => const {
    MissionStatus.confirmed,
    MissionStatus.onTheWay,
    MissionStatus.inProgress,
    MissionStatus.completionRequested,
    MissionStatus.completed,
    MissionStatus.paymentHeld,
    MissionStatus.awaitingRelease,
    MissionStatus.closed,
  }.contains(mission.status);

  bool get _isArchived => const {
    MissionStatus.completed,
    MissionStatus.paymentHeld,
    MissionStatus.awaitingRelease,
    MissionStatus.inDispute,
    MissionStatus.closed,
    MissionStatus.cancelled,
    MissionStatus.expired,
  }.contains(mission.status);

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _priceController.text = mission.budget.averageAmount.toInt().toString();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ─── MissionDetailBase — abstract overrides ──────────────────────────────

  @override
  Mission get widgetMission => widget.mission;

  @override
  Mission syncMission(BuildContext ctx) {
    if (!widget.isOwn) return mission;
    return ctx.watch<MissionProvider>().freelancerMissions.firstWhere(
      (m) => m.id == widget.mission.id,
      orElse: () => mission,
    );
  }

  @override
  bool get showTimeline => widget.isOwn;

  @override
  bool get canSeeFullAddress => widget.isOwn && _isAccepted;

  @override
  bool get isBottomHidden => false;

  @override
  Widget? buildHeroMenu(BuildContext ctx) {
    return DetailCircleBtn(
      icon: Icons.more_horiz_rounded,
      onTap: _showReportSheet,
    );
  }

  @override
  Widget buildTagsPrice(BuildContext ctx) {
    final daysLeft = mission.date.difference(DateTime.now()).inDays;
    final daysLabel = daysLeft > 0 ? '+$daysLeft jours' : "Aujourd'hui";
    final secondaryLabel = widget.isOwn
        ? MissionStatusUi.badgeLabel(
            status: mission.status,
            role: MissionUiRole.freelancer,
          )
        : '${mission.candidatesCount} reaction${mission.candidatesCount > 1 ? 's' : ''}';

    return Row(
      children: [
        DetailLuxuryPill(label: daysLabel),
        AppGap.w10,
        DetailLuxuryPill(label: secondaryLabel),
        const Spacer(),
        BudgetText(budget: mission.budget, large: true),
      ],
    );
  }

  @override
  Widget? buildFinanceExposureCard(BuildContext ctx) {
    if (!widget.isOwn || !MissionFinanceExposureCard.shouldDisplay(mission)) {
      return null;
    }
    return MissionFinanceExposureCard(
      mission: mission,
      role: MissionUiRole.freelancer,
    );
  }

  @override
  StatusBannerConfig? resolveBanner() {
    switch (mission.status) {
      case MissionStatus.confirmed:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.celebration_rounded,
          title: 'Vous avez ete selectionne',
          subtitle:
              'La mission vous est reservee. Confirmez votre disponibilite pour continuer.',
          style: DetailBannerStyle.card,
        );
      case MissionStatus.onTheWay:
        return StatusBannerConfig(
          color: AppColors.secondary,
          icon: Icons.directions_car_rounded,
          title: 'Vous êtes en route',
          subtitle: 'Le client suit votre arrivée depuis son détail mission.',
          pulse: true,
          style: DetailBannerStyle.card,
        );
      case MissionStatus.inProgress:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.handyman_rounded,
          title: 'Mission en cours',
          subtitle:
              'Continuez la prestation puis marquez-la comme terminée une fois finie.',
          pulse: true,
          style: DetailBannerStyle.card,
        );
      case MissionStatus.completionRequested:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          title: 'Fin signalée au client',
          subtitle:
              'Le client doit maintenant confirmer la mission ou signaler un problème.',
          style: DetailBannerStyle.card,
        );
      case MissionStatus.paymentHeld:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.lock_clock_rounded,
          title: '100€ sécurisés par le client',
          subtitle:
              'Le versement sera effectué automatiquement 24h après la livraison, sauf litige.',
          style: DetailBannerStyle.card,
        );
      case MissionStatus.completed:
      case MissionStatus.awaitingRelease:
        return StatusBannerConfig(
          color: AppColors.warning,
          icon: Icons.schedule_rounded,
          title: 'Versement sous 24h',
          subtitle:
              'Le client dispose de 24h pour signaler un problème. Sans retour, le paiement est versé automatiquement.',
          style: DetailBannerStyle.card,
        );
      case MissionStatus.closed:
        return StatusBannerConfig(
          color: AppColors.primary,
          icon: Icons.check_circle_outline_rounded,
          title: 'Mission terminée',
          subtitle:
              'Le paiement a été envoyé et la mission est maintenant clôturée.',
          style: DetailBannerStyle.card,
        );
      case MissionStatus.inDispute:
        return StatusBannerConfig(
          color: AppColors.error,
          icon: Icons.flag_rounded,
          title: 'Litige en cours — paiement suspendu',
          subtitle:
              'Le client a signalé un problème. Le versement est suspendu jusqu\'à résolution du litige.',
          style: DetailBannerStyle.card,
        );
      case MissionStatus.cancelled:
      case MissionStatus.expired:
        return StatusBannerConfig(
          color: AppColors.error,
          icon: Icons.close_rounded,
          title: 'Mission annulée',
          subtitle:
              "Cette mission est clôturée et aucune action supplémentaire n'est attendue.",
          style: DetailBannerStyle.card,
        );
      default:
        return null;
    }
  }

  @override
  Widget buildRoleSection(BuildContext ctx) {
    if (mission.client == null) return const SizedBox.shrink();

    final contactable = widget.isOwn && _isAccepted && !_isArchived;
    final children = <Widget>[
      FreelancerClientCard(
        client: mission.client!,
        onPhone: contactable ? _openPhoneClient : null,
        onChat: contactable ? _openChat : null,
      ),
    ];

    final today = DateTime.now();
    final isToday =
        mission.date.year == today.year &&
        mission.date.month == today.month &&
        mission.date.day == today.day;

    if (widget.isOwn &&
        isToday &&
        (mission.status == MissionStatus.confirmed ||
            mission.status == MissionStatus.onTheWay ||
            mission.status == MissionStatus.inProgress)) {
      children.add(
        FreelancerLocationShareCard(
          status: mission.status,
          onOpenMissionPilot: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => FreelancerTrackingPage(mission: mission),
            ),
          ),
        ),
      );
    }

    return Column(children: children);
  }

  @override
  Widget buildBottom(BuildContext ctx) {
    final alreadyApplied =
        !widget.isOwn &&
        ctx.watch<MissionProvider>().freelancerMissions.any(
          (m) => m.id == mission.id,
        );

    // Archivée
    if (_isArchived) {
      final (
        IconData icon,
        String label,
        String caption,
      ) = switch (mission.status) {
        MissionStatus.paymentHeld => (
          Icons.lock_clock_rounded,
          'Paiement sécurisé',
          '100€ sécurisés par le client — versement après livraison',
        ),
        MissionStatus.completed || MissionStatus.awaitingRelease => (
          Icons.schedule_rounded,
          'Versement sous 24h',
          'Le client dispose de 24h pour signaler un problème',
        ),
        MissionStatus.inDispute => (
          Icons.flag_rounded,
          'Litige en cours',
          'Versement suspendu jusqu\'à résolution',
        ),
        MissionStatus.closed => (
          Icons.check_circle_outline_rounded,
          'Mission terminée',
          mission.rating != null
              ? 'Note reçue : ${mission.rating}/5'
              : 'Paiement envoyé et mission clôturée',
        ),
        _ => (
          Icons.close_rounded,
          'Mission annulée',
          'Cette mission est maintenant closee',
        ),
      };
      // Pour les missions closes, proposer d'évaluer le client si pas encore fait
      if (mission.status == MissionStatus.closed) {
        return DetailBottomArea(
          caption: caption,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DetailReadonlyBadge(icon: icon, label: label),
              AppGap.h10,
              if (mission.client != null && !_hasRatedClient)
                AppButton(
                  label: 'Évaluer ${mission.client!.name}',
                  icon: Icons.star_rounded,
                  variant: ButtonVariant.outline,
                  onPressed: () => _openClientReview(ctx),
                ),
              AppGap.h8,
              AppButton(
                label: 'Voir mes revenus',
                variant: ButtonVariant.ghost,
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => const FreelancerActivityPage(),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return DetailBottomArea(
        caption: caption,
        child: DetailReadonlyBadge(icon: icon, label: label),
      );
    }

    // Candidature déjà envoyée (explorer) ou isOwn en attente
    if (alreadyApplied || (widget.isOwn && !_isAccepted)) {
      return DetailBottomArea(
        caption: 'En attente de la décision du client',
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: ctx.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: ctx.colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_rounded,
                color: ctx.colors.textSecondary,
                size: 18,
              ),
              AppGap.w8,
              Text(
                'Candidature envoyee',
                style: ctx.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mission déjà pourvue — aucune action disponible
    if (_isAccepted) return const SizedBox.shrink();

    // Default : Réagir à cette mission
    return DetailBottomArea(
      caption:
          'Il y a ${mission.candidatesCount} réaction${mission.candidatesCount > 1 ? 's' : ''} pour cette mission',
      child: DetailTealButton(
        label: 'Réagir à cette mission',
        onTap: _openProposalSheet,
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _openClientReview(BuildContext ctx) async {
    final rated = await Navigator.push<bool>(
      ctx,
      MaterialPageRoute(builder: (_) => ClientReviewPage(mission: mission)),
    );
    if (rated == true && mounted) {
      setState(() => _hasRatedClient = true);
    }
  }

  void _showReportSheet() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: FreelancerActionSheet(
        onReport: () {
          Navigator.pop(context);
          _confirmReport();
        },
      ),
    );
  }

  void _confirmReport() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      child: FreelancerReportConfirmSheet(
        missionTitle: mission.title,
        onConfirm: () {
          Navigator.pop(context);
          showAppSnackBar(
            context,
            'Mission signalee. Merci pour votre retour.',
          );
        },
      ),
    );
  }

  Future<void> _openChat() async {
    final client = mission.client;
    if (client == null) return;

    final conversationId = await context
        .read<MessagingProvider>()
        .findConversation(
          otherUserId: client.id,
          iAmClient: false,
          missionId: mission.id,
        );
    if (!mounted) return;

    if (conversationId == null) {
      _promptContactRequest(client);
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
          confirmedMissionTitle: mission.title,
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

  void _promptContactRequest(dynamic client) {
    showAppDialog(
      context: context,
      title: const Text('Demander à être contacté'),
      content: Text(
        'Le client n\'a pas encore ouvert de conversation. Voulez-vous lui envoyer une demande de contact pour la mission "${mission.title}" ?',
      ),
      confirmLabel: 'Envoyer la demande',
      cancelLabel: 'Annuler',
      onConfirm: () => _sendContactRequest(client),
    );
  }

  Future<void> _sendContactRequest(dynamic client) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final freelancerDisplayName =
        currentUser?.userMetadata?['first_name'] as String? ?? 'Le prestataire';

    try {
      await Supabase.instance.client.from('notifications').insert({
        'user_id': client.id,
        'type': 'mission',
        'title': 'Demande de contact',
        'body':
            '$freelancerDisplayName souhaite vous contacter pour la mission "${mission.title}".',
        'is_read': false,
      });
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Demande envoyée au client.',
        type: SnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Impossible d\'envoyer la demande. Réessayez.',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _openPhoneClient() async {
    final phone = mission.client?.phone;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openProposalSheet() {
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      child: FreelancerProposalSheet(
        mission: mission,
        priceController: _priceController,
        messageController: _messageController,
        onSubmit: (double price, String message) {
          context
              .read<MissionProvider>()
              .submitProposal(mission, price: price, message: message)
              .catchError((e) => debugPrint('submitProposal error: $e'));
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}
