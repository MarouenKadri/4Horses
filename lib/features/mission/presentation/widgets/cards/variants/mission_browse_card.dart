import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';

// ─── Variant : Marketplace freelancer ────────────────────────────────────────
// Responsabilité : afficher une mission disponible dans le feed.
// Card façon job board (Upwork) : pas de photo, la card est un dossier de
// décision — fraîcheur, titre, budget, extrait, confiance client, tension.
// ─────────────────────────────────────────────────────────────────────────────

class MissionBrowseCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onTap;
  final bool isApplied;

  const MissionBrowseCard({
    super.key,
    required this.mission,
    required this.onTap,
    this.isApplied = false,
  });

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return 'Il y a ${diff.inDays ~/ 7} sem';
  }

  @override
  Widget build(BuildContext context) {
    final client = mission.client;
    final distance = mission.address.distance;

    final trustParts = [
      if (client != null && client.isVerified) 'Client vérifié',
      mission.address.shortAddress,
      if (distance != null) distance,
    ].join(' · ');

    return Opacity(
      opacity: isApplied ? 0.72 : 1.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Fraîcheur + catégorie ────────────────────────────
                  Text(
                    '${_timeAgo(mission.createdAt)} · ${mission.categoryName.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: context.colors.textTertiary,
                    ),
                  ),
                  AppGap.h6,
                  // ── Titre ────────────────────────────────────────────
                  Text(
                    mission.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      fontSize: AppFontSize.body,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  AppGap.h6,
                  // ── Ligne budget ─────────────────────────────────────
                  Text(
                    mission.budget.detailedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (mission.description.isNotEmpty) ...[
                    AppGap.h8,
                    // ── Extrait description ────────────────────────────
                    Text(
                      mission.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                  AppGap.h10,
                  // ── Ligne de confiance client ──────────────────────
                  Row(
                    children: [
                      if (client != null && client.rating > 0) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.rating,
                        ),
                        AppGap.w3,
                        Text(
                          client.rating.toStringAsFixed(1),
                          style: context.text.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: context.text.labelSmall?.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          trustParts,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall?.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppGap.h8,
                  // ── Tension ────────────────────────────────────────
                  if (isApplied)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: context.colors.textTertiary,
                        ),
                        AppGap.w3,
                        Text(
                          'Postulé',
                          style: context.text.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      mission.candidatesCount > 0
                          ? '${mission.candidatesCount} candidat${mission.candidatesCount > 1 ? 's' : ''}'
                          : 'Soyez le premier à postuler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: context.colors.divider),
          ],
        ),
      ),
    );
  }
}
