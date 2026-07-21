import 'package:flutter/material.dart';

import '../../core/design/app_design_system.dart';

class AppCategoryItem {
  final String? id;
  final String label;
  final IconData icon;
  final Color color;

  const AppCategoryItem({
    this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class AppCategoryFilterBar extends StatelessWidget {
  final List<AppCategoryItem> items;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double height;

  const AppCategoryFilterBar({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 10,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected =
              selectedId == item.id || (selectedId == null && item.id == null);
          return AppCategoryChip(
            label: item.label,
            icon: item.icon,
            color: item.color,
            selected: isSelected,
            onTap: () => onSelect(item.id),
          );
        },
      ),
    );
  }
}

class AppCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.selected = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  static Color _tone(Color base, double delta) {
    final hsl = HSLColor.fromColor(base);
    final lightness = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStart = _tone(color, 0.06);
    final selectedEnd = _tone(color, -0.09);
    final borderColor = selected ? Colors.transparent : context.colors.border;
    final textColor = selected ? Colors.white : context.colors.textSecondary;
    final iconColor = selected ? Colors.white : context.colors.textSecondary;
    final iconBg = selected
        ? Colors.white.withValues(alpha: 0.18)
        : color.withValues(alpha: 0.12);

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [selectedStart, selectedEnd],
              )
            : null,
        color: selected ? null : context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: borderColor),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 12, color: iconColor),
          ),
          AppGap.w8,
          Text(
            label,
            style: context.text.labelLarge?.copyWith(
              fontSize: AppFontSize.md,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: chip,
      ),
    );
  }
}
