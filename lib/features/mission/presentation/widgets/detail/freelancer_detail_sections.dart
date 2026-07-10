import 'package:flutter/material.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../../../../freelancer/presentation/pages/client_profile_view.dart';
import 'mission_detail_primitives.dart';

// ─── FreelancerClientCard ─────────────────────────────────────────────────────

class FreelancerClientCard extends StatelessWidget {
  final ClientInfo client;
  final VoidCallback? onPhone;
  final VoidCallback? onChat;

  const FreelancerClientCard({
    super.key,
    required this.client,
    this.onPhone,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DetailSectionTitle(title: 'Publié par'),
          AppGap.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClientProfileView(
                      clientId: client.id,
                      clientName: client.name,
                      clientAvatar: client.avatarUrl,
                      rating: client.rating,
                      missionsCount: client.missionsCount,
                    ),
                  ),
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.border,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: client.avatarUrl.isNotEmpty
                      ? Image.network(
                          client.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _ClientAvatarFallback(name: client.name),
                        )
                      : _ClientAvatarFallback(name: client.name),
                ),
              ),
              AppGap.w10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.missionEntityNameStyle,
                          ),
                        ),
                        if (client.isVerified) ...[
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
                      'Client',
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
                          client.rating.toStringAsFixed(1),
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

class FreelancerLocationShareCard extends StatelessWidget {
  final MissionStatus status;
  final VoidCallback onOpenMissionPilot;

  const FreelancerLocationShareCard({
    super.key,
    required this.status,
    required this.onOpenMissionPilot,
  });

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      MissionStatus.confirmed => (
        icon: Icons.navigation_rounded,
        title: 'Code client requis',
        subtitle:
            'Quand vous arrivez, demandez le code de demarrage au client pour lancer officiellement la mission.',
        cta: 'Lancer le suivi',
        accent: AppColors.secondary,
      ),
      MissionStatus.onTheWay => (
        icon: Icons.location_searching_rounded,
        title: 'En route vers la mission',
        subtitle:
            'Une fois arrive, entrez le code donne par le client pour demarrer la mission.',
        cta: 'Gerer le suivi',
        accent: AppColors.primary,
      ),
      MissionStatus.inProgress => (
        icon: Icons.my_location_rounded,
        title: 'Position active sur mission',
        subtitle:
            'Le client peut verifier que vous etes bien sur place pendant l intervention.',
        cta: 'Voir le pilotage',
        accent: AppColors.primary,
      ),
      _ => (
        icon: Icons.location_disabled_rounded,
        title: 'Partage de position indisponible',
        subtitle:
            'Le suivi live apparait uniquement pour une mission confirmee ou en cours.',
        cta: 'Voir le pilotage',
        accent: context.colors.textTertiary,
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
                  Icons.info_outline_rounded,
                  size: 16,
                  color: config.accent,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Le partage live doit etre active depuis le pilotage de mission.',
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
          DetailTealButton(label: config.cta, onTap: onOpenMissionPilot),
        ],
      ),
    );
  }
}

class _ClientAvatarFallback extends StatelessWidget {
  final String name;
  const _ClientAvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      color: context.colors.surfaceAlt,
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: context.text.headlineSmall?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── FreelancerActionSheet ────────────────────────────────────────────────────

class FreelancerActionSheet extends StatelessWidget {
  final VoidCallback onReport;

  const FreelancerActionSheet({super.key, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Options',
      children: [
        AppActionSheetItem(
          icon: Icons.flag_outlined,
          title: 'Signaler cette mission',
          destructive: true,
          onTap: onReport,
        ),
      ],
    );
  }
}

// ─── FreelancerReportConfirmSheet ─────────────────────────────────────────────

class FreelancerReportConfirmSheet extends StatefulWidget {
  final String missionTitle;
  final VoidCallback onConfirm;

  const FreelancerReportConfirmSheet({
    super.key,
    required this.missionTitle,
    required this.onConfirm,
  });

  @override
  State<FreelancerReportConfirmSheet> createState() =>
      _FreelancerReportConfirmSheetState();
}

class _FreelancerReportConfirmSheetState
    extends State<FreelancerReportConfirmSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AppActionSheet(
      title: 'Signaler la mission ?',
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signaler la mission ?',
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
            AppGap.h18,
            Text(
              'Merci de nous aider à garder la plateforme sûre. Votre signalement sera examiné par notre équipe.',
              style: context.missionBodyStyle.copyWith(
                fontSize: AppFontSize.md,
                height: 1.55,
                color: AppColors.gray500,
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
            label: 'Signaler',
            variant: ButtonVariant.destructive,
            isLoading: _loading,
            onPressed: _loading
                ? null
                : () {
                    setState(() => _loading = true);
                    widget.onConfirm();
                  },
          ),
        ),
        AppGap.h12,
        Center(
          child: GestureDetector(
            onTap: _loading ? null : () => Navigator.pop(context),
            child: Text(
              'Annuler',
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

// ─── FreelancerProposalSheet ──────────────────────────────────────────────────

