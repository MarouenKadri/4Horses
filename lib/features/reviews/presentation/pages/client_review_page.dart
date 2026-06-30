import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design/app_design_system.dart';
import '../../../mission/data/models/mission.dart';
import '../../../mission/presentation/widgets/shared/mission_shared_widgets.dart';
import '../../../profile/profile_provider.dart';
import '../providers/review_provider.dart';

/// Page permettant au freelancer d'évaluer le client après une mission closed.
class ClientReviewPage extends StatefulWidget {
  final Mission mission;

  const ClientReviewPage({super.key, required this.mission});

  @override
  State<ClientReviewPage> createState() => _ClientReviewPageState();
}

class _ClientReviewPageState extends State<ClientReviewPage> {
  int _starRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.mission.client;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        title: 'Évaluer le client',
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
                  // ─── Header client ───
                  AppSurfaceCard(
                    padding: AppPadding.cardLarge,
                    color: context.colors.surface,
                    borderRadius: BorderRadius.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mission.title,
                          style: context.text.displaySmall,
                        ),
                        if (client != null) ...[
                          AppGap.h12,
                          Row(
                            children: [
                              UserAvatar(
                                imageUrl: client.avatarUrl,
                                radius: 22,
                                showVerified: client.isVerified,
                              ),
                              AppGap.w12,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    client.name,
                                    style: context.text.titleSmall,
                                  ),
                                  Text(
                                    'Client',
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ─── Étoiles ───
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
                        Text(
                          'Notez ce client (optionnel)',
                          style: context.text.titleSmall,
                        ),
                        AppGap.h12,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _starRating = i + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Icon(
                                  i < _starRating
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 40,
                                  color: i < _starRating
                                      ? AppColors.rating
                                      : context.colors.border,
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
                              style: context.text.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ─── Commentaire ───
                  AppSurfaceCard(
                    margin: AppInsets.h16v8,
                    padding: AppPadding.cardLarge,
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppDesign.radius14),
                    border: Border.all(color: context.colors.border),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Commentaire (optionnel)',
                          style: context.text.titleSmall,
                        ),
                        AppGap.h12,
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText:
                                'Décrivez votre expérience avec ce client…',
                            hintStyle: context.text.bodyMedium?.copyWith(
                              color: context.colors.textTertiary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.input),
                              borderSide:
                                  BorderSide(color: context.colors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.input),
                              borderSide:
                                  BorderSide(color: context.colors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.input),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            filled: true,
                            fillColor: context.colors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Action bar ───
          AppSection(
            color: context.colors.surface,
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            child: AppButton(
              label: _starRating > 0 ? 'Envoyer mon avis' : 'Passer',
              icon: _starRating > 0
                  ? Icons.send_rounded
                  : Icons.arrow_forward_rounded,
              onPressed: _isSubmitting ? null : _submit,
              variant: ButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final client = widget.mission.client;
    if (client == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSubmitting = true);

    if (_starRating > 0) {
      final reviewProvider = context.read<ReviewProvider>();
      final profile = context.read<ProfileProvider>().profile;

      final err = await reviewProvider.submitReview(
        revieweeId: client.id,
        reviewerName: profile?.fullName ?? 'Prestataire',
        reviewerAvatar: profile?.avatarUrl,
        rating: _starRating,
        missionId: widget.mission.id,
        missionTitle: widget.mission.title,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;

      if (err != null) {
        debugPrint('submitReview (client) warning: $err');
      } else {
        showAppSnackBar(
          context,
          'Avis envoyé',
          type: SnackBarType.success,
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String _ratingLabel(int stars) => switch (stars) {
        1 => 'Décevant',
        2 => 'Passable',
        3 => 'Bien',
        4 => 'Très bien',
        _ => 'Excellent !',
      };
}
