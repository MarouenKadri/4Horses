import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';
import '../../domain/entities/review.dart';
import 'review_card.dart';

class ReviewsTab extends StatelessWidget {
  final List<Review> reviews;
  final String emptyLabel;
  final bool isReceived;

  const ReviewsTab({
    super.key,
    required this.reviews,
    required this.emptyLabel,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 120),
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sentiment_neutral_rounded,
                  size: 64,
                  color: context.colors.textHint,
                ),
                AppGap.h12,
                Text(
                  emptyLabel,
                  style: context.reviewEmptyStateStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppInsets.h16,
      itemCount: reviews.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ReviewCard(review: reviews[i], isReceived: isReceived),
      ),
    );
  }
}
