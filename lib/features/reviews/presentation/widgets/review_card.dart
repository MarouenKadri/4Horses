import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../domain/entities/review.dart';
import '../mappers/satisfaction_ui.dart';
import '../utils/review_formatters.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isReceived;

  const ReviewCard({super.key, required this.review, required this.isReceived});

  @override
  Widget build(BuildContext context) {
    final satisfaction = review.satisfaction;
    return AppSurfaceCard(
      padding: AppInsets.a16,
      border: Border.all(color: context.colors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: AppReviewMetrics.reviewAvatarRadius,
                backgroundColor: context.colors.surfaceAlt,
                backgroundImage: review.reviewerAvatar.isNotEmpty
                    ? NetworkImage(review.reviewerAvatar)
                    : null,
                child: review.reviewerAvatar.isEmpty
                    ? Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName[0].toUpperCase()
                            : '?',
                        style: context.text.titleMedium?.copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName, style: context.reviewAuthorStyle),
                    AppGap.h4,
                    Text(
                      isReceived ? 'Avis recu' : 'Avis donne',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppGap.h4,
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: AppReviewMetrics.missionIconSize,
                          color: context.colors.textHint,
                        ),
                        AppGap.w5,
                        Expanded(
                          child: Text(
                            review.missionTitle,
                            style: context.reviewMissionStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppGap.w8,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppSurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    color: isReceived
                        ? AppColors.secondary
                        : context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppDesign.radius14Lg),
                    child: Text(
                      isReceived ? 'Recu' : 'Donne',
                      style: context.text.labelMedium?.copyWith(
                        color: isReceived
                            ? AppColors.primary
                            : context.colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AppGap.h6,
                  Text(
                    formatReviewDate(review.createdAt),
                    style: context.reviewDateStyle,
                  ),
                  AppGap.h6,
                  AppSurfaceCard(
                    padding: AppInsets.h10v5,
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppDesign.radius14Lg),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          satisfaction.icon,
                          size: AppReviewMetrics.satisfactionIconSize,
                          color: AppColors.primary,
                        ),
                        AppGap.w5,
                        Text(
                          satisfaction.label,
                          style: context.reviewBadgeStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            AppGap.h12,
            Divider(height: 1, color: context.colors.divider),
            AppGap.h12,
            Text(review.comment, style: context.reviewCommentStyle),
          ],
        ],
      ),
    );
  }
}
