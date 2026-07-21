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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.bedroom_baby_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
        AppGap.w10,
        Text(
          '4horses',
          style: context.text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: context.colors.textPrimary,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
