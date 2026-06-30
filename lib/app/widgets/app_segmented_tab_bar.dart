import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/app_design_system.dart';

/// Data model for one segmented tab.
class AppSegmentedTab {
  final IconData? icon;
  final String label;
  const AppSegmentedTab({this.icon, required this.label});
}

/// Pill-style segmented tab bar — source de vérité UI pour tous les onglets.
///
/// Deux modes :
///   • Avec [controller]    → connecté à un TabController / TabBarView
///   • Avec [selectedIndex] → mode standalone (setState), pas besoin de TabController
///
/// Design : actif = fond noir + texte blanc, inactif = fond blanc + bordure grise.
class AppSegmentedTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<AppSegmentedTab> tabs;

  // Mode TabController
  final TabController? controller;

  // Mode standalone
  final int? selectedIndex;
  final ValueChanged<int>? onChanged;

  const AppSegmentedTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.selectedIndex,
    this.onChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final tabController = controller ?? DefaultTabController.maybeOf(context);
    final isStandalone = tabController == null;

    if (tabs.isEmpty) return const SizedBox.shrink();

    if (isStandalone) {
      return _buildPills(
        context,
        getSelected: (_) => selectedIndex ?? 0,
        onTap: (i) {
          HapticFeedback.selectionClick();
          onChanged?.call(i);
        },
      );
    }

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) => _buildPills(
        context,
        getSelected: (_) => tabController.index,
        onTap: (i) {
          HapticFeedback.selectionClick();
          tabController.animateTo(
            i,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }

  Widget _buildPills(
    BuildContext context, {
    required int Function(int) getSelected,
    required void Function(int) onTap,
  }) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(tabs.length, (index) {
            final selected = getSelected(index) == index;
            final isLast = index == tabs.length - 1;

            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8),
              child: GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.inkDark : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? AppColors.inkDark : AppColors.gray50,
                    ),
                    boxShadow: selected
                        ? const [
                            BoxShadow(
                              color: AppColors.blackAlpha09,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tabs[index].icon != null) ...[
                        Icon(
                          tabs[index].icon,
                          size: 13,
                          color: selected ? Colors.white : AppColors.gray600,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        tabs[index].label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
