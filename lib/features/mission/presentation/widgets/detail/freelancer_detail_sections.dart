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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    border: Border.all(color: context.colors.border, width: 1.5),
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
          DetailSectionTitle(
            title: 'Suivi mission',
            trailing: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: config.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(config.icon, size: 20, color: config.accent),
            ),
          ),
          AppGap.h8,
          Text(
            config.title,
            style: context.missionPrimaryValueStyle,
          ),
          AppGap.h14,
          Text(
            config.subtitle,
            style: context.missionEmphasisBodyStyle,
          ),
          AppGap.h16,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
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
          DetailTealButton(
            label: config.cta,
            onTap: onOpenMissionPilot,
          ),
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
      color: AppColors.primary.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: context.text.headlineSmall?.copyWith(color: AppColors.primary),
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

class FreelancerProposalSheet extends StatefulWidget {
  final Mission mission;
  final TextEditingController priceController;
  final TextEditingController messageController;
  final void Function(double price, String message) onSubmit;

  const FreelancerProposalSheet({
    super.key,
    required this.mission,
    required this.priceController,
    required this.messageController,
    required this.onSubmit,
  });

  @override
  State<FreelancerProposalSheet> createState() =>
      _FreelancerProposalSheetState();
}

class _FreelancerProposalSheetState extends State<FreelancerProposalSheet> {
  late final List<int> _quickAmounts;
  int _messageLength = 0;

  @override
  void initState() {
    super.initState();
    final base = widget.mission.budget.totalAmount.toInt();
    _quickAmounts = base > 0
        ? [
            (base * 0.8).round(),
            (base * 0.9).round(),
            base,
            (base * 1.1).round(),
            (base * 1.2).round(),
          ]
        : [50, 80, 100, 120, 150];
    _messageLength = widget.messageController.text.length;
    widget.messageController.addListener(_onMsg);
  }

  void _onMsg() {
    if (mounted) setState(() => _messageLength = widget.messageController.text.length);
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onMsg);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final priceText = widget.priceController.text;
    final canSubmit = priceText.isNotEmpty &&
        int.tryParse(priceText) != null &&
        int.parse(priceText) > 0;

    return SizedBox(
      height: h * 0.88,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // ── Handle ────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // ── Title row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Votre proposition',
                      style: context.text.headlineLarge?.copyWith(
                        fontSize: AppFontSize.h2Lg,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // ── Scrollable fields ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.mission.title} • ${widget.mission.formattedDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.missionEmphasisBodyStyle,
                    ),
                    AppGap.h24,
                    Text(
                      'Votre tarif',
                      style: context.missionSectionLabelStyle.copyWith(
                        letterSpacing: 0.2,
                      ),
                    ),
                    AppGap.h10,
                    TextFormField(
                      controller: widget.priceController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      onChanged: (_) => setState(() {}),
                      style: context.text.displayMedium?.copyWith(
                        fontSize: 38,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1.2,
                        color: context.colors.textPrimary,
                      ),
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText: '0',
                        hintStyle: context.text.displayMedium?.copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -1.2,
                          color: context.colors.border,
                        ),
                        contentPadding: EdgeInsets.zero,
                        noBorder: true,
                        fillColor: Colors.transparent,
                      ).copyWith(
                        prefixText: '€ ',
                        prefixStyle: context.text.headlineLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    AppGap.h8,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts.map((amount) {
                        final isActive =
                            widget.priceController.text == amount.toString();
                        return GestureDetector(
                          onTap: () {
                            widget.priceController.text = amount.toString();
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.black
                                  : context.colors.surfaceAlt,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$amount €',
                              style: context.missionButtonStyle.copyWith(
                                fontSize: AppFontSize.base,
                                color: isActive
                                    ? Colors.white
                                    : context.colors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    AppGap.h28,
                    Row(
                      children: [
                        Text(
                          'Message au client',
                          style: context.missionSectionLabelStyle.copyWith(
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_messageLength/400',
                          style: context.missionSubtleCaptionStyle.copyWith(
                            color: context.colors.textHint,
                          ),
                        ),
                      ],
                    ),
                    AppGap.h10,
                    TextFormField(
                      controller: widget.messageController,
                      maxLines: 5,
                      maxLength: 400,
                      buildCounter:
                          (_, {required currentLength, required isFocused, maxLength}) =>
                              null,
                      style: context.missionBodyStyle.copyWith(height: 1.5),
                      decoration: AppInputDecorations.formField(
                        context,
                        hintText:
                            'Présentez-vous, vos atouts, votre expérience...',
                        hintStyle: context.missionBodyStyle.copyWith(
                          height: 1.5,
                          color: context.colors.textHint,
                        ),
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                        radius: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Submit button ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(22, 12, 22, 16 + bottomPad),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: AppButton(
                label: 'Envoyer ma proposition',
                variant: ButtonVariant.black,
                isEnabled: canSubmit,
                onPressed: canSubmit
                    ? () => widget.onSubmit(
                          double.parse(widget.priceController.text),
                          widget.messageController.text,
                        )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
