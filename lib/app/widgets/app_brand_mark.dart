import 'package:flutter/material.dart';

import '../../core/design/app_design_system.dart';

/// Marque « 4horses » : logomark + wordmark, pour l'app bar des accueils.
/// (Logomark en code tant qu'aucun asset vectoriel n'est fourni.)
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.bedroom_baby_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        AppGap.w8,
        Text(
          '4horses',
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
