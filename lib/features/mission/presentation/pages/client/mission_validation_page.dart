import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/design/app_design_system.dart';
import '../../../data/models/mission.dart';
import '../../mission_provider.dart';
import '../../widgets/shared/mission_shared_widgets.dart';
import '../../widgets/shared/status_timeline.dart';
import '../../../../../features/notifications/notification_provider.dart';
import '../../../../../features/notifications/data/models/app_notification.dart';
import '../../../../../features/reviews/presentation/providers/review_provider.dart';
import '../../../../../features/profile/profile_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ✅ Inkern - MissionValidationPage (Client)
/// Écran de validation après signalement de fin : confirmation, note, litige.
/// ═══════════════════════════════════════════════════════════════════════════

class MissionValidationPage extends StatefulWidget {
  final Mission mission;

  const MissionValidationPage({super.key, required this.mission});

  @override
  State<MissionValidationPage> createState() => _MissionValidationPageState();
}

class _MissionValidationPageState extends State<MissionValidationPage> {
  int _starRating = 0;

  double get _prestaAmount => widget.mission.budget.averageAmount * 0.9;
  double get _cigaleAmount => widget.mission.budget.averageAmount * 0.1;

  @override
  Widget build(BuildContext context) {
    final presta = widget.mission.assignedPresta;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Valider la mission',
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───
                  AppSurfaceCard(
                    padding: AppPadding.cardLarge,
                    color: context.colors.surface,
                    borderRadius: BorderRadius.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.mission.title, style: context.text.displaySmall),
                        if (presta != null) ...[
                          AppGap.h12,
                          Row(children: [
                            UserAvatar(imageUrl: presta.avatarUrl, radius: 22, showVerified: presta.isVerified),
                            AppGap.w12,
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(presta.name, style: context.text.titleSmall),
                              RatingWidget(rating: presta.rating, reviewsCount: presta.reviewsCount, compact: true),
                            ]),
                          ]),
                        ],
                      ],
                    ),
                  ),

                  // ─── Timeline ───
                  StatusTimeline(status: widget.mission.status),

                  // ─── Récap paiement ───
                  AppSurfaceCard(
                    margin: AppInsets.h16v8,
                    padding: AppPadding.cardLarge,
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppDesign.radius14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.payments_rounded, size: 20, color: AppColors.primary),
                          AppGap.w8,
                          Text('Récapitulatif du paiement', style: context.text.titleSmall),
                        ]),
                        AppGap.h16,
                        _PaymentRow(
                          label: 'Montant total bloqué',
                          amount: widget.mission.budget.averageAmount,
                          bold: true,
                        ),
                        const Padding(
                          padding: AppInsets.v10,
                          child: Divider(height: 1),
                        ),
                        _PaymentRow(
                          label: 'Versement prestataire (90%)',
                          amount: _prestaAmount,
                          color: AppColors.primary,
                        ),
                        AppGap.h8,
                        _PaymentRow(
                          label: 'Commission Inkern (10%)',
                          amount: _cigaleAmount,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  // ─── Notation ───
                  AppSurfaceCard(
                    margin: AppInsets.h16v8,
                    padding: AppPadding.cardLarge,
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius14),
                    border: Border.all(color: context.colors.border),
                    boxShadow: AppShadows.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notez la prestation (optionnel)', style: context.text.titleSmall),
                        AppGap.h12,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return GestureDetector(
                              onTap: () => setState(() => _starRating = i + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  i < _starRating ? Icons.star_rounded : Icons.star_border_rounded,
                                  size: 40,
                                  color: i < _starRating ? AppColors.rating : context.colors.border,
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_starRating > 0) ...[
                          AppGap.h8,
                          Center(
                            child: Text(
                              _ratingLabel(_starRating),
                              style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Boutons d'action ───
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return AppSection(
      color: context.colors.surface,
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: 'Valider et libérer ${_prestaAmount.round()} €',
            icon: Icons.check_circle_rounded,
            onPressed: _validate,
            variant: ButtonVariant.primary,
          ),
          AppGap.h10,
          AppButton(
            label: 'Ouvrir un litige',
            variant: ButtonVariant.outline,
            icon: Icons.flag_rounded,
            onPressed: _openDispute,
          ),
        ],
      ),
    );
  }

  Future<void> _validate() async {
    final missionProvider = context.read<MissionProvider>();
    final notifProvider = context.read<NotificationProvider>();
    final reviewProvider = context.read<ReviewProvider>();
    final profile = context.read<ProfileProvider>().profile;

    await missionProvider.updateMissionStatus(widget.mission.id, MissionStatus.closed);

    // Soumettre l'avis si une note a été donnée
    final presta = widget.mission.assignedPresta;
    if (_starRating > 0 && presta != null) {
      final err = await reviewProvider.submitReview(
        revieweeId: presta.id,
        reviewerName: profile?.fullName ?? 'Client',
        reviewerAvatar: profile?.avatarUrl,
        rating: _starRating,
        missionId: widget.mission.id,
        missionTitle: widget.mission.title,
      );
      if (err != null) debugPrint('submitReview warning (non-blocking): $err');
    }

    if (!mounted) return;

    notifProvider.addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotifType.payment,
      title: 'Paiement reçu',
      body: 'Vous avez reçu ${_prestaAmount.round()} € pour la mission "${widget.mission.title}".',
      timeAgo: 'À l\'instant',
    ));

    Navigator.pop(context);
  }

  void _openDispute() {
    showAppDialog(
      context: context,
      title: const Text('Ouvrir un litige'),
      content: const Text(
        'Un conseiller Inkern vous contactera sous 24h. Le paiement reste bloqué pendant la procédure.',
      ),
      cancelLabel: 'Annuler',
      confirmLabel: 'Confirmer',
      confirmVariant: ButtonVariant.destructive,
      onConfirm: () {
        Navigator.pop(context);
        final missionProvider = context.read<MissionProvider>();
        final notifProvider = context.read<NotificationProvider>();

        missionProvider.updateMissionStatus(widget.mission.id, MissionStatus.inDispute);

        notifProvider.addNotification(AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: NotifType.mission,
          title: 'Litige ouvert',
          body: 'Un litige a été ouvert pour la mission "${widget.mission.title}".',
          timeAgo: 'À l\'instant',
        ));

        Navigator.pop(context);
      },
    );
  }

  String _ratingLabel(int stars) => switch (stars) {
    1 => 'Décevant',
    2 => 'Passable',
    3 => 'Bien',
    4 => 'Très bien',
    _ => 'Excellent !',
  };
}

// ─── Ligne de paiement ────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  final Color? color;

  const _PaymentRow({required this.label, required this.amount, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.textPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.text.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.w600 : null)),
        Text(
          '${amount.round()} €',
          style: bold
              ? context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: effectiveColor)
              : context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: effectiveColor),
        ),
      ],
    );
  }
}
