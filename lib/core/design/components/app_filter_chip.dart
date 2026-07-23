import 'package:flutter/material.dart';

import '../app_design_system.dart';

/// Pilule de filtre réutilisable (bottom sheets de filtres — missions,
/// prestataires…) : fond teinté + bordure fine quand sélectionnée, pour
/// rester cohérent entre les différents écrans de filtrage de l'app.
class AppFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.45)
                : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? accent : context.colors.textTertiary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: context.text.labelMedium!.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? accent : context.colors.textSecondary,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
