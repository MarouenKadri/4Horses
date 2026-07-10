import 'package:flutter/material.dart';
import '../../../../../../core/design/app_design_system.dart';
import '../../../../data/models/mission.dart';
import '../../shared/mission_shared_widgets.dart' show BudgetText;

// ─── Variant : Marketplace freelancer ────────────────────────────────────────
// Responsabilité : afficher une mission disponible dans le feed.
// Rangée plate façon résultats TikTok, cohérente avec FreelancerListTile :
// vignette à gauche · infos au centre · budget à droite · filet fin dessous.
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

  @override
  Widget build(BuildContext context) {
    final distance = mission.address.distance;

    return Opacity(
      opacity: isApplied ? 0.72 : 1.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(mission: mission),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mission.categoryName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: context.colors.textTertiary,
                                ),
                              ),
                            ),
                            if (distance != null)
                              Text(
                                ' · $distance',
                                style: context.text.labelSmall?.copyWith(
                                  color: context.colors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                        AppGap.h4,
                        Text(
                          mission.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        AppGap.h4,
                        Text(
                          '${mission.formattedDate} · ${mission.address.shortAddress}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppGap.w12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BudgetText(budget: mission.budget),
                      AppGap.h4,
                      if (isApplied)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 12,
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
                      else if (mission.candidatesCount > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 12,
                              color: context.colors.textHint,
                            ),
                            AppGap.w3,
                            Text(
                              '${mission.candidatesCount}',
                              style: context.text.labelSmall?.copyWith(
                                color: context.colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, indent: 84, color: context.colors.divider),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Mission mission;

  const _Thumbnail({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mission-img-${mission.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 72,
          height: 72,
          child: mission.images.isNotEmpty
              ? Image.network(
                  mission.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallback(context),
                )
              : _fallback(context),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) => ColoredBox(
        color: context.colors.surfaceAlt,
        child: Icon(
          mission.categoryIcon,
          size: 26,
          color: context.colors.textTertiary,
        ),
      );
}
