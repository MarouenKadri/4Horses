import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';

class ReviewsErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ReviewsErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: AppInsets.a16,
      color: context.colors.surface,
      border: Border.all(color: context.colors.border),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.colors.textSecondary),
          AppGap.w12,
          Expanded(child: Text(message, style: context.text.bodyMedium)),
          AppGap.w8,
          AppButton(
            label: 'Reessayer',
            variant: ButtonVariant.ghost,
            width: null,
            height: 40,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
