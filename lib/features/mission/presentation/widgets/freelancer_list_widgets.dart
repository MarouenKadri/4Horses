import 'package:flutter/material.dart';

import '../../../../core/design/app_design_system.dart';

class DistanceBadge extends StatelessWidget {
  final String distance;
  final bool compact;

  const DistanceBadge({
    super.key,
    required this.distance,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: compact ? 14 : 16,
          color: context.colors.textTertiary,
        ),
        AppGap.w3,
        Text(
          distance,
          style: compact
              ? context.text.labelMedium
              : context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
