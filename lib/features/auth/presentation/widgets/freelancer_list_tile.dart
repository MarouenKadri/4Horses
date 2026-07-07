import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../data/models/freelancer.dart';

/// Rangée freelancer façon « recherche utilisateurs » TikTok :
/// avatar rond · nom + coche · métier + note · tarif + missions · bouton Voir.
/// Fond blanc, pensée pour une ListView avec filets fins.
class FreelancerListTile extends StatelessWidget {
  final Freelancer freelancer;
  final int missionsCount;
  final VoidCallback? onTap;

  const FreelancerListTile({
    super.key,
    required this.freelancer,
    this.missionsCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _Avatar(imageUrl: freelancer.imageUrl, name: freelancer.name),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          freelancer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (freelancer.isVerified) ...[
                        AppGap.w4,
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.info,
                        ),
                      ],
                    ],
                  ),
                  AppGap.h2,
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          freelancer.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                      if (freelancer.rating > 0) ...[
                        Text(
                          ' · ',
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.textHint,
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.rating,
                        ),
                        AppGap.w2,
                        Text(
                          freelancer.rating.toStringAsFixed(1),
                          style: context.text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppGap.h2,
                  Text(
                    missionsCount > 0
                        ? '${freelancer.job} · $missionsCount missions'
                        : freelancer.job,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelMedium?.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.w12,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.inkDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Voir',
                style: context.text.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final String name;

  const _Avatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.hardEdge,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial(context),
            )
          : _initial(context),
    );
  }

  Widget _initial(BuildContext context) => ColoredBox(
        color: AppColors.secondary,
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      );
}
