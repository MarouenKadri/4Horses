import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design/app_design_system.dart';

/// Data model for one segmented tab.
class AppSegmentedTab {
  final IconData? icon;
  final String label;

  /// Met l'onglet en alerte visuelle (icône + texte rouges, clignotant) —
  /// prioritaire sur l'état sélectionné/inactif habituel.
  final bool alert;

  const AppSegmentedTab({this.icon, required this.label, this.alert = false});
}

/// Pill-style segmented tab bar — source de vérité UI pour tous les onglets.
///
/// Deux modes :
///   • Avec [controller]    → connecté à un TabController / TabBarView
///   • Avec [selectedIndex] → mode standalone (setState), pas besoin de TabController
///
/// Design : actif = fond noir + texte blanc, inactif = fond blanc + bordure grise.
class AppSegmentedTabBar extends StatefulWidget
    implements PreferredSizeWidget {
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
  State<AppSegmentedTabBar> createState() => _AppSegmentedTabBarState();
}

class _AppSegmentedTabBarState extends State<AppSegmentedTabBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final Animation<double> _blinkOpacity;

  bool get _hasAlert => widget.tabs.any((t) => t.alert);

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _blinkOpacity = Tween<double>(begin: 1.0, end: 0.35).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    if (_hasAlert) _blinkController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AppSegmentedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hadAlert = oldWidget.tabs.any((t) => t.alert);
    if (_hasAlert && !hadAlert) {
      _blinkController.repeat(reverse: true);
    } else if (!_hasAlert && hadAlert) {
      _blinkController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabController =
        widget.controller ?? DefaultTabController.maybeOf(context);
    final isStandalone = tabController == null;

    if (widget.tabs.isEmpty) return const SizedBox.shrink();

    if (isStandalone) {
      return _buildPills(
        context,
        getSelected: (_) => widget.selectedIndex ?? 0,
        onTap: (i) {
          HapticFeedback.selectionClick();
          widget.onChanged?.call(i);
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
        children: List<Widget>.generate(widget.tabs.length, (index) {
          final tab = widget.tabs[index];
          final selected = getSelected(index) == index;
          final alertColor = context.colors.error;
          final color = tab.alert
              ? alertColor
              : (selected
                    ? context.colors.textPrimary
                    : context.colors.textTertiary);

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _blinkOpacity,
                        builder: (context, child) => Opacity(
                          opacity: tab.alert ? _blinkOpacity.value : 1.0,
                          child: child,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tab.icon != null) ...[
                              Icon(tab.icon, size: 16, color: color),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                tab.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.labelLarge?.copyWith(
                                  fontWeight: selected || tab.alert
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
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
