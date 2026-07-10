import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import 'mission_detail_primitives.dart';

// ─── ClientCandidatesCard ─────────────────────────────────────────────────────

class ClientCandidatesCard extends StatelessWidget {
  final int count;
  final VoidCallback onViewCandidates;

  const ClientCandidatesCard({
    super.key,
    required this.count,
    required this.onViewCandidates,
  });

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DetailSectionTitle(title: 'Candidatures'),
          AppGap.h16,
          Row(
            children: [
              SizedBox(
                width: 74,
                height: 32,
                child: Stack(
                  children: List.generate(3, (index) {
                    final visible = index < count && count > 0;
                    return Positioned(
                      left: index * 18.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: visible
                              ? context.colors.surfaceAlt
                              : context.colors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: visible
                              ? AppColors.ink
                              : context.colors.textHint,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Text(
                  count > 0
                      ? '$count candidat${count > 1 ? 's' : ''} interesse${count > 1 ? 's' : ''}'
                      : 'Aucune candidature pour le moment',
                  style: context.missionPrimaryValueStyle.copyWith(
                    fontSize: AppFontSize.base,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h18,
          DetailTealButton(
            label: 'Voir les candidatures',
            onTap: count > 0 ? onViewCandidates : null,
          ),
        ],
      ),
    );
  }
}

// ─── ClientPrestaCard ─────────────────────────────────────────────────────────

class ClientPrestaCard extends StatelessWidget {
  final PrestaInfo presta;
  final MissionStatus status;
  final int? rating;
  final VoidCallback? onPhone;
  final VoidCallback? onChat;
  final VoidCallback? onViewProfile;

  const ClientPrestaCard({
    super.key,
    required this.presta,
    required this.status,
    this.rating,
    this.onPhone,
    this.onChat,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final agreedPrice = presta.acceptedPrice ?? '100 €';
    final ratingValue = rating ?? presta.rating;

    return DetailSectionCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailSectionTitle(
            title: 'Prestataire choisi',
            trailing: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.inkDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Convenu', style: context.missionDarkOverlineStyle),
                  AppGap.h4,
                  Text(agreedPrice, style: context.missionDarkValueStyle),
                ],
              ),
            ),
          ),
          AppGap.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onViewProfile,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.border,
                      width: 1.6,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: presta.avatarUrl.isNotEmpty
                      ? Image.network(
                          presta.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _PrestaAvatarFallback(name: presta.name),
                        )
                      : _PrestaAvatarFallback(name: presta.name),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            presta.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.missionEntityNameStyle,
                          ),
                        ),
                        if (presta.isVerified) ...[
                          AppGap.w8,
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: context.colors.surfaceAlt,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colors.border),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppGap.h4,
                    Text(
                      'Prestataire confirmé',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.missionEntityMetaStyle,
                    ),
                    AppGap.h6,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.rating,
                        ),
                        AppGap.w4,
                        Text(
                          ratingValue.toStringAsFixed(1),
                          style: context.missionEntityRatingStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGap.h18,
          Row(
            children: [
              if (onPhone != null)
                Expanded(
                  child: DetailSecondaryButton(
                    label: 'Appeler',
                    onTap: onPhone,
                    icon: Icons.phone_rounded,
                  ),
                ),
              if (onPhone != null && onChat != null) AppGap.w10,
              if (onChat != null)
                Expanded(
                  child: DetailTealButton(
                    label: 'Message',
                    onTap: onChat,
                    icon: Icons.chat_bubble_rounded,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClientTrackingCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onOpenTracking;

  const ClientTrackingCard({
    super.key,
    required this.mission,
    this.onOpenTracking,
  });

  @override
  Widget build(BuildContext context) {
    final prestaName = mission.assignedPresta?.name ?? 'Votre prestataire';
    final startCode = mission.startCode;
    final config = switch (mission.status) {
      MissionStatus.confirmed => (
        icon: Icons.schedule_send_rounded,
        title: 'Code de demarrage pret',
        subtitle:
            'Communiquez ce code a $prestaName uniquement quand il arrive pour lancer la mission.',
        accent: context.colors.textTertiary,
        cta: 'Voir le suivi',
      ),
      MissionStatus.onTheWay => (
        icon: Icons.navigation_rounded,
        title: '$prestaName est en route',
        subtitle:
            'Le suivi en direct doit vous permettre de voir sa progression jusqu a l adresse.',
        accent: AppColors.secondary,
        cta: 'Ouvrir le suivi',
      ),
      MissionStatus.inProgress => (
        icon: Icons.my_location_rounded,
        title: 'Prestataire sur place',
        subtitle:
            '$prestaName est actuellement sur la mission. Le suivi reste visible pendant l intervention.',
        accent: AppColors.primary,
        cta: 'Voir la position',
      ),
      MissionStatus.completionRequested => (
        icon: Icons.task_alt_rounded,
        title: 'Le prestataire a signale la fin',
        subtitle:
            'Vérifiez la prestation puis confirmez la mission ou signalez un problème.',
        accent: AppColors.warning,
        cta: 'Verifier la mission',
      ),
      _ => (
        icon: Icons.location_disabled_rounded,
        title: 'Suivi indisponible',
        subtitle: 'Aucune position live a afficher pour cette mission.',
        accent: context.colors.textTertiary,
        cta: null,
      ),
    };

    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DetailSectionTitle(title: 'Suivi mission'),
          AppGap.h8,
          Text(config.title, style: context.missionPrimaryValueStyle),
          AppGap.h14,
          Text(config.subtitle, style: context.missionEmphasisBodyStyle),
          if (startCode != null &&
              (mission.status == MissionStatus.confirmed ||
                  mission.status == MissionStatus.onTheWay)) ...[
            AppGap.h16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(AppDesign.radius12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code de demarrage',
                          style: context.missionDarkOverlineStyle.copyWith(
                            letterSpacing: 0.2,
                          ),
                        ),
                        AppGap.h8,
                        Text(
                          '${startCode.substring(0, 3)} ${startCode.substring(3)}',
                          style: context.missionHeroTitleStyle.copyWith(
                            letterSpacing: 2.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppGap.w12,
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: startCode));
                        if (context.mounted) {
                          showAppSnackBar(
                            context,
                            'Code de demarrage copie',
                            icon: Icons.copy_rounded,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            AppGap.w6,
                            Text(
                              'Copier',
                              style: context.missionButtonStyle.copyWith(
                                fontSize: AppFontSize.md,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppGap.h16,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppDesign.radius12),
            ),
            child: Row(
              children: [
                Icon(
                  mission.status == MissionStatus.confirmed
                      ? Icons.hourglass_top_rounded
                      : Icons.location_searching_rounded,
                  size: 16,
                  color: config.accent,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    mission.status == MissionStatus.confirmed
                        ? 'Le suivi apparaitra automatiquement quand le prestataire demarrera le trajet.'
                        : mission.status == MissionStatus.completionRequested
                        ? 'La mission est en attente de votre retour avant de passer au paiement.'
                        : 'Le tracking live est prevu ici pour suivre le trajet du prestataire.',
                    style: context.missionEmphasisBodyStyle.copyWith(
                      fontSize: AppFontSize.smHalf,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (config.cta != null) ...[
            AppGap.h16,
            DetailTealButton(label: config.cta!, onTap: onOpenTracking),
          ],
        ],
      ),
    );
  }
}

class ClientCompletionRequestedCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onConfirm;
  final VoidCallback onDispute;

  const ClientCompletionRequestedCard({
    super.key,
    required this.mission,
    required this.onConfirm,
    required this.onDispute,
  });

  @override
  Widget build(BuildContext context) {
    final prestaName = mission.assignedPresta?.name ?? 'Le prestataire';
    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DetailSectionTitle(title: 'Fin de mission'),
          AppGap.h8,
          Text(
            'Fin de mission signalee',
            style: context.missionPrimaryValueStyle,
          ),
          AppGap.h14,
          Text(
            '$prestaName a signalé avoir terminé la mission. Confirmez la fin si tout est bon ou signalez un problème.',
            style: context.missionEmphasisBodyStyle,
          ),
          AppGap.h16,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppDesign.radius12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Sans action de votre part, le paiement pourra ensuite etre libere automatiquement.',
                    style: context.missionEmphasisBodyStyle.copyWith(
                      fontSize: AppFontSize.smHalf,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.h16,
          Row(
            children: [
              Expanded(
                child: DetailSecondaryButton(
                  label: 'Signaler',
                  onTap: onDispute,
                ),
              ),
              AppGap.w10,
              Expanded(
                child: DetailTealButton(label: 'Confirmer', onTap: onConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrestaAvatarFallback extends StatelessWidget {
  final String name;

  const _PrestaAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return Container(
      color: context.colors.surfaceAlt,
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: context.missionEntityNameStyle.copyWith(
          fontSize: AppFontSize.h2,
          fontWeight: FontWeight.w600,
          color: context.colors.textTertiary,
        ),
      ),
    );
  }
}

// ─── ClientActionSheet ────────────────────────────────────────────────────────

class ClientActionSheet extends StatelessWidget {
  final bool canModify;
  final bool canCancel;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  const ClientActionSheet({
    super.key,
    required this.canModify,
    required this.canCancel,
    required this.onEdit,
    required this.onShare,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Options',
      children: [
        if (canModify) ...[
          AppActionSheetItem(
            icon: Icons.edit_outlined,
            title: 'Modifier la mission',
            onTap: onEdit,
          ),
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ],
        AppActionSheetItem(
          icon: Icons.ios_share_outlined,
          title: 'Partager la mission',
          onTap: onShare,
        ),
        if (canCancel) ...[
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          AppActionSheetItem(
            icon: Icons.delete_outline,
            title: 'Annuler la mission',
            destructive: true,
            onTap: onCancel,
          ),
        ],
      ],
    );
  }
}

// ─── ClientCancelSheet ────────────────────────────────────────────────────────

class ClientCancelSheet extends StatefulWidget {
  final String missionTitle;
  final DateTime missionStart;
  final double missionAmount;
  final VoidCallback onConfirm;

  const ClientCancelSheet({
    super.key,
    required this.missionTitle,
    required this.missionStart,
    required this.missionAmount,
    required this.onConfirm,
  });

  @override
  State<ClientCancelSheet> createState() => _ClientCancelSheetState();
}

class _ClientCancelSheetState extends State<ClientCancelSheet> {
  bool _loading = false;

  bool get _isRefund100 {
    final startsIn = widget.missionStart.difference(DateTime.now());
    return startsIn.inMinutes >= 24 * 60;
  }

  double get _refundRate => _isRefund100 ? 1.0 : 0.5;
  double get _refundAmount => widget.missionAmount * _refundRate;

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Annuler la mission ?',
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Annuler la mission ?',
              style: context.missionSectionTitleStyle.copyWith(
                color: AppColors.snow,
              ),
            ),
            AppGap.h6,
            Text(
              widget.missionTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.missionBodyStyle.copyWith(
                fontSize: AppFontSize.md,
                color: AppColors.gray500,
              ),
            ),
            AppGap.h14,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: _isRefund100
                    ? AppColors.info.withValues(alpha: 0.12)
                    : AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isRefund100
                      ? AppColors.info.withValues(alpha: 0.26)
                      : AppColors.warning.withValues(alpha: 0.26),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRefund100
                        ? 'Remboursement 100% (annulation > 24h)'
                        : 'Remboursement 50% (annulation <= 24h / jour J)',
                    style: context.missionButtonStyle.copyWith(
                      fontSize: AppFontSize.smHalf,
                      fontWeight: FontWeight.w700,
                      color: AppColors.snow,
                    ),
                  ),
                  AppGap.h4,
                  Text(
                    'Montant estime: ${_refundAmount.toStringAsFixed(0)} €',
                    style: context.missionSubtleCaptionStyle.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h24,
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
            AppGap.h24,
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppButton(
            label: 'Confirmer l\'annulation',
            variant: ButtonVariant.destructive,
            isLoading: _loading,
            onPressed: _loading
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    setState(() => _loading = true);
                    widget.onConfirm();
                  },
          ),
        ),
        AppGap.h14,
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Garder la mission',
              style: context.missionEmphasisBodyStyle.copyWith(
                fontSize: AppFontSize.base,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
