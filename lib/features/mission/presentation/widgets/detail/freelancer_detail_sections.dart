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
        title: 'Prêt pour le départ',
        subtitle:
            'Partez vers l\'adresse du client — une fois sur place, démarrez la mission depuis le suivi.',
        cta: 'Lancer le suivi',
        accent: AppColors.primary,
        info: 'Activez le suivi dès que vous partez vers l\'adresse du client.',
      ),
      MissionStatus.onTheWay => (
        icon: Icons.location_searching_rounded,
        title: 'En route vers la mission',
        subtitle:
            'Une fois arrivé chez le client, démarrez la mission depuis le suivi.',
        cta: 'Gérer le suivi',
        accent: AppColors.primary,
        info: 'Votre position est partagée en direct avec le client.',
      ),
      MissionStatus.inProgress => (
        icon: Icons.my_location_rounded,
        title: 'Position active sur mission',
        subtitle:
            'Le client peut vérifier que vous êtes bien sur place pendant l\'intervention.',
        cta: 'Voir le pilotage',
        accent: AppColors.primary,
        info: 'Signalez la fin de la mission une fois l\'intervention terminée.',
      ),
      _ => (
        icon: Icons.location_disabled_rounded,
        title: 'Partage de position indisponible',
        subtitle:
            'Le suivi live apparaît uniquement pour une mission confirmée ou en cours.',
        cta: 'Voir le pilotage',
        accent: context.colors.textTertiary,
        info: 'Le suivi live n\'est pas disponible pour le moment.',
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
                    config.info,
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

// ─── FreelancerProposalSheet ──────────────────────────────────────────────────

