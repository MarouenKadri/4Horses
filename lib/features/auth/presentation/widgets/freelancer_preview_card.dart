import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../data/models/freelancer.dart';

/// Carte freelancer façon TikTok : photo plein cadre, dégradé léger,
/// légende (métier), puis une seule ligne mini-avatar · nom · note.
/// Le tarif reste visible en pastille translucide (impératif marketplace).
class FreelancerPreviewCard extends StatelessWidget {
  final Freelancer freelancer;
  final VoidCallback? onTap;
  final double? width;
  final int missionsCount;
  final int reviewsCount;

  const FreelancerPreviewCard({
    super.key,
    required this.freelancer,
    this.onTap,
    this.width,
    this.missionsCount = 0,
    this.reviewsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Image plein cadre ──────────────────────────────────
              freelancer.imageUrl.isNotEmpty
                  ? Image.network(
                      freelancer.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _AvatarFallback(name: freelancer.name),
                    )
                  : _AvatarFallback(name: freelancer.name),

              // ── Dégradé bas, léger ─────────────────────────────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.blackAlpha55,
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // ── Tarif (haut droite, translucide) ───────────────────
              if (freelancer.job.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.40),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      freelancer.job,
                      style: context.text.labelSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),

              // ── Légende + ligne auteur (bas) ───────────────────────
              Positioned(
                left: 10,
                right: 10,
                bottom: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (freelancer.subtitle.isNotEmpty) ...[
                      Text(
                        freelancer.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelMedium!.copyWith(
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    Row(
                      children: [
                        _MiniAvatar(
                          imageUrl: freelancer.imageUrl,
                          name: freelancer.name,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            freelancer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                        if (freelancer.isVerified) ...[
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: AppColors.info,
                          ),
                        ],
                        const Spacer(),
                        if (freelancer.rating > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: AppColors.rating,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            freelancer.rating.toStringAsFixed(1),
                            style: context.text.labelSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ] else if (missionsCount > 0) ...[
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 11,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$missionsCount',
                            style: context.text.labelSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;

  const _MiniAvatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1,
        ),
      ),
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
        color: AppColors.primary,
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: context.text.labelSmall!.copyWith(
              fontSize: AppFontSize.micro,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      );
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.30),
            AppColors.primary.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: context.text.displayMedium!.copyWith(
            fontSize: AppFontSize.d2,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
