import 'package:flutter/material.dart';
import '../../core/design/app_design_system.dart';
import 'bottom_nav/app_nav_config.dart' show NavItem;

export 'bottom_nav/app_nav_config.dart' show NavItem;

/// ─── Floating bottom nav bar ─────────────────────────────────────────────────
class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavItem> items;
  final Map<int, int> badgeCounts;

  /// Action centrale (ex. bouton Publier) insérée dans la rangée
  /// comme une colonne à part entière — même largeur que les onglets.
  final Widget? centerAction;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
    this.badgeCounts = const {},
    this.centerAction,
  });

  @override
  Widget build(BuildContext context) {
    final navTiles = List.generate(
      items.length,
      (i) => Expanded(
        child: _NavTile(
          item: items[i],
          selected: currentIndex == i,
          onTap: () => onItemSelected(i),
          badgeCount: badgeCounts[i] ?? 0,
          isFirst: i == 0,
          isLast: i == items.length - 1,
        ),
      ),
    );
    final rowChildren = centerAction != null
        ? <Widget>[
            ...navTiles.take(items.length ~/ 2),
            Expanded(child: Center(child: centerAction)),
            ...navTiles.skip(items.length ~/ 2),
          ]
        : navTiles;

    return AppNavBarSurface(
      child: SizedBox(height: 80, child: Row(children: rowChildren)),
    );
  }
}

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isFirst;
  final bool isLast;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppNavMetrics.tapAnimationMs),
      reverseDuration: const Duration(
        milliseconds: AppNavMetrics.tapReverseAnimationMs,
      ),
    );
    _tapScale = Tween<double>(
      begin: 1.0,
      end: AppNavMetrics.tapScaleEnd,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) => _tapController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = context.colors.primary;
    final labelActiveColor = context.colors.textPrimary;
    final inactiveColor = context.colors.textTertiary;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: ScaleTransition(
          scale: _tapScale,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppNavItemPill(
                    selected: widget.selected,
                    child: Icon(
                      widget.selected
                          ? widget.item.activeIcon
                          : widget.item.icon,
                      size: widget.selected ? 26 : 24,
                      color: widget.selected ? activeColor : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.label,
                    style:
                        (widget.selected
                                ? context.navLabelSelectedStyle
                                : context.navLabelStyle)
                            .copyWith(
                              fontSize: AppFontSize.tinyHalf,
                              color: widget.selected
                                  ? labelActiveColor
                                  : inactiveColor,
                              height: 1,
                            ),
                  ),
                ],
              ),
              if (widget.badgeCount > 0)
                Positioned(
                  top: AppNavMetrics.badgeTopOffset,
                  right: AppNavMetrics.badgeRightOffset,
                  child: AppCountBadge(
                    label: widget.badgeCount > 9
                        ? '9+'
                        : '${widget.badgeCount}',
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: AppInsets.h4v1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// FAB animé — étendu par défaut, réduit au scroll
class AnimatedFab extends StatelessWidget {
  final bool expanded;
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const AnimatedFab({
    super.key,
    required this.expanded,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);
    const collapsedSize = AppNavMetrics.fabHeight;
    const expandedHorizontalPadding = 18.0;
    const collapsedHorizontalPadding = 15.0;
    final targetWidth = expanded ? 176.0 : collapsedSize;

    return AnimatedContainer(
      duration: const Duration(milliseconds: AppNavMetrics.fabAnimationMs),
      curve: Curves.easeOutCubic,
      width: targetWidth,
      height: AppNavMetrics.fabHeight,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: expanded ? 0.26 : 0.18,
            ),
            blurRadius: expanded ? 26 : 18,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            splashColor: Colors.white.withValues(alpha: 0.14),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded
                    ? expandedHorizontalPadding
                    : collapsedHorizontalPadding,
              ),
              child: Row(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Flexible(
                    child: ClipRect(
                      child: AnimatedAlign(
                        duration: const Duration(
                          milliseconds: AppNavMetrics.fabAnimationMs,
                        ),
                        curve: Curves.easeOutCubic,
                        widthFactor: expanded ? 1 : 0,
                        alignment: Alignment.centerLeft,
                        child: AnimatedOpacity(
                          duration: const Duration(
                            milliseconds: AppNavMetrics.fabAnimationMs,
                          ),
                          curve: Curves.easeOutCubic,
                          opacity: expanded ? 1 : 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: context.navFabLabelStyle.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
