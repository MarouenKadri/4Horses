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
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.divider)),
      ),
      child: Row(
        children: List<Widget>.generate(tabs.length, (index) {
          final selected = getSelected(index) == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tabs[index].icon != null) ...[
                            Icon(
                              tabs[index].icon,
                              size: 16,
                              color: selected
                                  ? context.colors.textPrimary
                                  : context.colors.textHint,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              tabs[index].label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelLarge?.copyWith(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? context.colors.textPrimary
                                    : context.colors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2,
                    width: 28,
                    color: selected
                        ? context.colors.textPrimary
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
