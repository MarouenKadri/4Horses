import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../domain/entities/review.dart';
import '../../domain/value_objects/satisfaction.dart';
import '../mappers/satisfaction_ui.dart';

class ReviewsSummary extends StatelessWidget {
  final List<Review> reviews;

  const ReviewsSummary({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    final recommended = reviews
        .where(
          (review) =>
              review.satisfaction == Satisfaction.satisfait ||
              review.satisfaction == Satisfaction.tresSatisfait,
        )
        .length;
    final pctRecommend = total == 0 ? 0 : ((recommended / total) * 100).round();

    return AppSurfaceCard(
      margin: AppInsets.a16,
      padding: AppInsets.a20,
      border: Border.all(color: context.colors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSurfaceCard(
                padding: AppInsets.a12,
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppDesign.radius14),
                child: const Icon(
                  Icons.sentiment_very_satisfied_rounded,
                  size: AppReviewMetrics.summaryIconSize,
                  color: AppColors.primary,
                ),
              ),
              AppGap.w16,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pctRecommend%',
                    style: context.reviewSummaryScoreStyle,
                  ),
                  Text(
                    'recommandent · $total avis',
                    style: context.reviewSummaryMetaStyle,
                  ),
                ],
              ),
            ],
          ),
          AppGap.h20,
          Divider(height: 1, color: context.colors.divider),
          AppGap.h16,
          ...Satisfaction.values.reversed.map((satisfaction) {
            final count = reviews
                .where((review) => review.satisfaction == satisfaction)
                .length;
            final pct = total == 0 ? 0.0 : count / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    satisfaction.icon,
                    size: 20,
                    color: context.colors.textSecondary,
                  ),
                  AppGap.w10,
                  SizedBox(
                    width: AppReviewMetrics.distributionLabelWidth,
                    child: Text(
                      satisfaction.label,
                      style: context.reviewDistributionLabelStyle,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDesign.radius4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: context.colors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: AppReviewMetrics.progressHeight,
                      ),
                    ),
                  ),
                  AppGap.w10,
                  SizedBox(
                    width: AppReviewMetrics.distributionCountWidth,
                    child: Text(
                      '$count',
                      style: context.reviewDistributionCountStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
